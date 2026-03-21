import SwiftUI

// MARK: - About View Card Sections

extension AboutView {
    var allergiesAndOrdersCards: some View {
        let allergies = person.allergyItems ?? []
        let foodOrders = person.foodOrderItems ?? []
        return HStack(spacing: Spacing.md) {
            NavigationLink(destination: AllergiesListView(person: person)) {
                AboutCard(
                    title: String(localized: "Allergies", comment: "About: allergies card title"),
                    icon: "cross.case.fill",
                    iconColor: CategoryPalette.color(for: "amber"),
                    iconBackground: CategoryPalette.color(for: "amber").opacity(Opacity.iconBackground),
                    previewText: allergies.first?.name,
                    countText: allergies.isEmpty
                        ? nil
                        : String(
                            localized: "\(allergies.count) allergies",
                            comment: "About: allergies count label"
                        )
                )
            }
            .buttonStyle(.plain)

            NavigationLink(destination: FoodOrdersView(person: person)) {
                AboutCard(
                    title: String(localized: "Orders", comment: "About: food orders card title"),
                    icon: "menucard.fill",
                    iconColor: CategoryPalette.color(for: "eucalyptus"),
                    iconBackground: CategoryPalette.color(for: "eucalyptus").opacity(Opacity.iconBackground),
                    previewText: foodOrders.first?.place,
                    countText: foodOrders.isEmpty
                        ? nil
                        : String(
                            localized: "\(foodOrders.count) orders",
                            comment: "About: food orders count label"
                        )
                )
            }
            .buttonStyle(.plain)
        }
        .opacity(showLikesCards ? 1 : 0)
        .offset(y: showLikesCards ? 0 : 12)
        .animation(.motionAware(.easeOut(duration: 0.4).delay(0.3)), value: showLikesCards)
    }

    // MARK: - Pet Names & Dreams Cards

    var petNamesAndDreamsCards: some View {
        let petNames = person.petNames ?? []
        let dreams = person.dreams ?? []
        return HStack(spacing: Spacing.md) {
            NavigationLink(destination: PetNamesView(person: person)) {
                AboutCard(
                    title: String(localized: "Pet Names", comment: "About: pet names card title"),
                    icon: "heart.text.clipboard",
                    iconColor: CategoryPalette.color(for: "rose"),
                    iconBackground: CategoryPalette.color(for: "rose").opacity(Opacity.iconBackground),
                    previewText: petNames.first?.text,
                    countText: petNames.isEmpty
                        ? nil
                        : String(
                            localized: "\(petNames.count) pet names",
                            comment: "About: pet names count label"
                        )
                )
            }
            .buttonStyle(.plain)

            NavigationLink(destination: DreamsView(person: person)) {
                AboutCard(
                    title: String(localized: "Dreams", comment: "About: dreams card title"),
                    icon: "sparkles",
                    iconColor: CategoryPalette.color(for: "lavender"),
                    iconBackground: CategoryPalette.color(for: "lavender").opacity(Opacity.iconBackground),
                    previewText: dreams.first?.text,
                    countText: dreams.isEmpty
                        ? nil
                        : String(
                            localized: "\(dreams.count) dreams",
                            comment: "About: dreams count label"
                        )
                )
            }
            .buttonStyle(.plain)
        }
        .opacity(showLikesCards ? 1 : 0)
        .offset(y: showLikesCards ? 0 : 12)
        .animation(.motionAware(.easeOut(duration: 0.4).delay(0.4)), value: showLikesCards)
    }
}
