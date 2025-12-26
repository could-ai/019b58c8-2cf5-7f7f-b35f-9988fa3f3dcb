enum UtilityType { electricity, water }

/// Abstract base class representing a Consumer.
/// This demonstrates polymorphism: different consumer types implement
/// the bill calculation logic differently.
abstract class Consumer {
  String name;
  double unitsConsumed;

  Consumer({required this.name, required this.unitsConsumed});

  /// Polymorphic method to calculate bill amount.
  /// Implementation depends on the concrete subclass (Residential, Commercial, etc.)
  double calculateBill(UtilityType utilityType);

  /// Returns the display name of the consumer type
  String get typeLabel;
  
  /// Returns the rate description for the UI
  String getRateDescription(UtilityType utilityType);
}

/// Residential Consumer: Typically has lower, tiered rates.
class ResidentialConsumer extends Consumer {
  ResidentialConsumer({required super.name, required super.unitsConsumed});

  @override
  String get typeLabel => "Residential";

  @override
  double calculateBill(UtilityType utilityType) {
    if (utilityType == UtilityType.electricity) {
      // Electricity: Tiered pricing
      // First 100 units @ $0.10, remaining @ $0.15
      if (unitsConsumed <= 100) {
        return unitsConsumed * 0.10;
      } else {
        return (100 * 0.10) + ((unitsConsumed - 100) * 0.15);
      }
    } else {
      // Water: Flat low rate
      // $1.50 per unit
      return unitsConsumed * 1.50;
    }
  }

  @override
  String getRateDescription(UtilityType utilityType) {
    if (utilityType == UtilityType.electricity) {
      return "Tiered: $0.10/unit (first 100), $0.15/unit (excess)";
    } else {
      return "Flat Rate: $1.50/unit";
    }
  }
}

/// Commercial Consumer: Higher flat rates.
class CommercialConsumer extends Consumer {
  CommercialConsumer({required super.name, required super.unitsConsumed});

  @override
  String get typeLabel => "Commercial";

  @override
  double calculateBill(UtilityType utilityType) {
    if (utilityType == UtilityType.electricity) {
      // Electricity: Flat high rate
      // $0.25 per unit
      return unitsConsumed * 0.25;
    } else {
      // Water: Higher flat rate
      // $2.50 per unit
      return unitsConsumed * 2.50;
    }
  }
  
  @override
  String getRateDescription(UtilityType utilityType) {
    if (utilityType == UtilityType.electricity) {
      return "Flat Rate: $0.25/unit";
    } else {
      return "Flat Rate: $2.50/unit";
    }
  }
}

/// Industrial Consumer: Highest rates + fixed base charge.
class IndustrialConsumer extends Consumer {
  IndustrialConsumer({required super.name, required super.unitsConsumed});

  @override
  String get typeLabel => "Industrial";

  @override
  double calculateBill(UtilityType utilityType) {
    double baseCharge = 50.0; // Fixed monthly connection fee
    if (utilityType == UtilityType.electricity) {
      // Electricity: $0.20 per unit + base charge
      return baseCharge + (unitsConsumed * 0.20);
    } else {
      // Water: $3.00 per unit + base charge
      return baseCharge + (unitsConsumed * 3.00);
    }
  }
  
  @override
  String getRateDescription(UtilityType utilityType) {
    if (utilityType == UtilityType.electricity) {
      return "$0.20/unit + $50.00 Base Charge";
    } else {
      return "$3.00/unit + $50.00 Base Charge";
    }
  }
}
