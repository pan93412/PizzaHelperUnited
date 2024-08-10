// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

#if PizzaHelper4Genshin
public let sharedBundleIDHeader = "Canglong.GenshinPizzaHepler"
public let appGroupID = "group.GenshinPizzaHelper"
#elseif PizzaHelper4HSR
public let sharedBundleIDHeader = "Canglong.HSRPizzaHelper"
public let appGroupID = "group.Canglong.HSRPizzaHelper"
#else
public let sharedBundleIDHeader: String = {
    switch Bundle.main.bundleIdentifier {
    case "Canglong.GenshinPizzaHepler": return "Canglong.GenshinPizzaHepler"
    case "Canglong.HSRPizzaHelper": return "Canglong.HSRPizzaHelper"
    default: return "org.pizzastudio.UnitedPizzaHelper"
    }
}()

public let appGroupID: String = {
    switch Bundle.main.bundleIdentifier {
    case "Canglong.GenshinPizzaHepler": return "group.GenshinPizzaHelper"
    case "Canglong.HSRPizzaHelper": return "group.Canglong.HSRPizzaHelper"
    default: return "group.pizzastudio.UnitedPizzaHelper"
    }
}()
#endif