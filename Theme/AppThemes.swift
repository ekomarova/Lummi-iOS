//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  - Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//  - Neither the name of the copyright holder nor the names of its contributors
//    may be used to endorse or promote products derived from this software
//    without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
//  THE POSSIBILITY OF SUCH DAMAGE.
//

import SwiftUI

struct DarkTheme: AppTheme {
    var bgGradient = LinearGradient(
        colors: [.black, .black],
        startPoint: .top, endPoint: .bottom
    )
    var backgroundColor: Color = .black
    
    var textColor: Color = .white
    var inactiveOpacity: Double = 0.35
    
    var todayColor: Color = .black
    var dayFilledColor: Color = .orange
    var calendarBackground: Color = .white
    var calendarContentColor: Color = .black
    
    var bottomPanelStarIconColor: Color = .orange
}

struct LightTheme: AppTheme {
    var bgGradient = LinearGradient(
        colors: [.white, .white],
        startPoint: .top, endPoint: .bottom
    )
    var backgroundColor: Color = .white
    
    var textColor: Color = .black
    var inactiveOpacity: Double = 0.35
    
    var todayColor: Color = .white
    var dayFilledColor: Color = .orange
    var calendarBackground: Color = .black
    var calendarContentColor: Color = .white
    
    var bottomPanelStarIconColor: Color = .orange
}
