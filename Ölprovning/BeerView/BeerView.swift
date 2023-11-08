//
//  AddBeer.swift
//  Beer Tests
//
//  Created by Petter Gustafsson on 2023-07-30.
//
import SwiftUI
import CoreData

struct BeerView: View {
    @EnvironmentObject var beerManager: BeerManager
    @EnvironmentObject var viewModel: BeerViewModel
    @Environment(\.managedObjectContext) var moc
    
    @State private var showingAddBeerView = false
    @State private var selectedBeerType: String? = nil
    @State private var isFirstBeerAdded = UserDefaults.standard.bool(forKey: "isFirstBeerAdded")

    @AppStorage("isBlurOn") private var isBlurOn = false
    @AppStorage("blurRadius") private var blurRadius = 1.0
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var beerTypes: FetchedResults<BeerType>
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("BackgroundImageBeer")
                    .resizable()
                    .edgesIgnoringSafeArea(.top)
                    .blur(radius: isBlurOn ? CGFloat(blurRadius) : 0)
                
                VStack(spacing: 20) {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(beerTypes, id: \.self) { beerType in
                                NavigationLink(
                                    destination: BeerDetailView(viewModel: viewModel, beerType: beerType),
                                    label: {
                                        Text(beerType.name!)
                                            .padding()
                                            .frame(maxWidth: 150)
                                            .foregroundColor(.orange)
                                            .background(Color.black)
                                            .cornerRadius(15)
                                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white, lineWidth: 1))
                                            .font(.title2)
                                            .fontWeight(.bold)
                                    }
                                )
                            }
                        }
                    }
                    .safeAreaInset(edge: .top) {
                        VStack() {
                            HStack() {
                                Spacer()
                                Text("Beer")
                                    .font(.largeTitle.weight(.bold))
                                    .foregroundStyle(Color.orange)
                                Spacer()
                            }
                        }
                        .padding()
                        .background(LinearGradient(colors: [.black.opacity(0.1), .orange.opacity(0.6)],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                            .overlay(.ultraThinMaterial)
                        )
                    }
                    .navigationBarHidden(true)
                    
                    Button(action: {
                        showingAddBeerView.toggle()
                    }) {
                        Text("Add beer")
                            .padding()
                            .frame(maxWidth: 200, maxHeight: 60)
                            .foregroundColor(.white)
                            .background(.linearGradient(colors: [.orange, .black], startPoint: .top, endPoint: .bottomTrailing))
                            .cornerRadius(15)
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white, lineWidth: 1))
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    //.shadow(color: .orange , radius: 25, y: 5)
                    .padding(.bottom, 30)
                    .sheet(isPresented: $showingAddBeerView) {
                        AddBeerView(
                            onSave: { newBeer, beerType in
                                beerManager.addBeer(newBeer, for: beerType)
                                
                                let fetchRequest: NSFetchRequest<BeerType>
                                fetchRequest = BeerType.fetchRequest()
                                fetchRequest.predicate = NSPredicate(format: "name LIKE %@", beerType)
                                fetchRequest.fetchLimit = 1
                                let types = try? moc.fetch(fetchRequest)
                                let t: BeerType
                                if types != nil && !types!.isEmpty {
                                    t = types![0]
                                } else {
                                    t = BeerType(context: moc)
                                    t.id = UUID()
                                    t.name = beerType
                                    t.beers = []
                                }
                                
                                let beer = Beer(context: moc)
                                beer.id = UUID()
                                beer.image = newBeer.beerImageData!
                                beer.name = newBeer.beerName
                                beer.score = newBeer.beerPoints
                                beer.note = newBeer.beerNote
                                beer.beerType = t
                                try? moc.save()
                                
                                
                                // Set isFirstBeerAdded to true
                                isFirstBeerAdded = true
                                UserDefaults.standard.set(isFirstBeerAdded, forKey: "isFirstBeerAdded")
                                
                                isBlurOn = true
                            },
                            selectedBeerType: $selectedBeerType,
                            isPresented: $showingAddBeerView
                        )
                    }
                }
            }
        }
    }
}
