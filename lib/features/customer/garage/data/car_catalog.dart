/// Brand → models for the add-car pickers, for the Egyptian market.
///
/// Client-side because there is no backend catalogue: `POST /vehicles` takes
/// `make` and `model` as free `string|max:60`, and no brand/model endpoint
/// exists to drive a picker from. So this list is a convenience, never a
/// constraint — see [otherOption].
library;

/// Sentinel for "my car isn't listed", which reveals a free-text field.
///
/// Load-bearing, not a courtesy: this form gates entry to the app (#39), and
/// the list below will always be missing somebody's car. Without an escape
/// hatch an unlisted brand means no vehicle, and no vehicle means no Home —
/// the user would be locked out permanently by a hardcoded list. Any UI built
/// on [carCatalog] must offer this.
const otherOption = '__other__';

/// Brands common on Egyptian roads, with their frequently seen models.
/// Deliberately not exhaustive — [otherOption] covers the tail.
const Map<String, List<String>> carCatalog = {
  'Toyota': [
    'Corolla',
    'Yaris',
    'Camry',
    'Hilux',
    'Fortuner',
    'RAV4',
    'Land Cruiser',
    'C-HR',
  ],
  'Hyundai': [
    'Elantra',
    'Accent',
    'Tucson',
    'Creta',
    'i10',
    'i30',
    'Sonata',
    'Santa Fe',
  ],
  'Kia': ['Cerato', 'Rio', 'Sportage', 'Picanto', 'Seltos', 'Sorento', 'Soul'],
  'Nissan': ['Sunny', 'Sentra', 'Qashqai', 'Juke', 'X-Trail', 'Patrol'],
  'Chevrolet': ['Optra', 'Aveo', 'Captiva', 'Lanos', 'Cruze', 'N300'],
  'Renault': ['Logan', 'Sandero', 'Duster', 'Megane', 'Clio', 'Captur'],
  'Skoda': ['Octavia', 'Fabia', 'Rapid', 'Superb', 'Kodiaq', 'Karoq'],
  'Volkswagen': ['Golf', 'Passat', 'Polo', 'Tiguan', 'Jetta'],
  'BMW': ['3 Series', '5 Series', '7 Series', 'X1', 'X3', 'X5'],
  'Mercedes-Benz': ['A-Class', 'C-Class', 'E-Class', 'S-Class', 'GLA', 'GLC'],
  'Peugeot': ['208', '301', '308', '3008', '5008'],
  'Fiat': ['Tipo', 'Punto', '500', 'Shahin'],
  'Opel': ['Astra', 'Corsa', 'Insignia', 'Grandland'],
  'Suzuki': ['Swift', 'Dzire', 'Vitara', 'Ertiga', 'Alto'],
  'Honda': ['Civic', 'Accord', 'CR-V', 'City'],
  'Mitsubishi': ['Lancer', 'Attrage', 'Xpander', 'Pajero', 'Eclipse Cross'],
  'MG': ['MG5', 'MG6', 'ZS', 'RX5', 'HS'],
  'Chery': ['Tiggo 3', 'Tiggo 4', 'Tiggo 7', 'Tiggo 8', 'Arrizo 5'],
  'Geely': ['Emgrand', 'Coolray', 'Azkarra'],
  'BYD': ['F3', 'Song', 'Han', 'Atto 3'],
  'Jeep': ['Wrangler', 'Grand Cherokee', 'Compass', 'Renegade'],
  'Seat': ['Ibiza', 'Leon', 'Arona', 'Ateca'],
  'Citroen': ['C3', 'C4', 'C5 Aircross', 'C-Elysee'],
  'Ford': ['Focus', 'Fiesta', 'Escape', 'EcoSport', 'Ranger'],
  'Mazda': ['Mazda2', 'Mazda3', 'Mazda6', 'CX-5'],
  'Audi': ['A3', 'A4', 'A6', 'Q3', 'Q5'],
  'Speranza': ['A516', 'Tiggo', 'Envy'],
  'Daewoo': ['Lanos', 'Nubira', 'Juliet'],
};

/// Brands in display order.
List<String> get carBrands => carCatalog.keys.toList();

/// Models for [brand], or empty when it is unknown or [otherOption].
List<String> modelsFor(String? brand) => carCatalog[brand] ?? const [];
