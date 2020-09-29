//
// MMMCommonCore. Part of MMMTemple.
// Copyright (C) 2016-2020 MediaMonks. All rights reserved.
//

import Foundation

extension MMMNetworkConditioner {
	open func conditionBlock(
		context: String = "",
		estimatedResponseLength: Int = 0,
		block: @escaping MMMNetworkConditionerBlock
	) {
		__conditionBlock(block, inContext: context, estimatedResponseLength: estimatedResponseLength)
	}
}
