//
//  Daylight_calendarView.swift
//  Daylight calendar
//
//  Created by Hallvard kristiansen on 04/01/2020.
//  Copyright © 2020 Hallvard kristiansen. All rights reserved.
//

import Cocoa
import Foundation
import ScreenSaver


var run_clock = false
var run_intro = false
var run_outro = false
let debug = false
let latLong = [52.5167, 13.3833]    // Berlin
//let latLong = [59.9139, 10.7522]  // Oslo
//let latLong = [63.2875, 8.3757]   // Aure
//let latLong = [51.5074, 0.1278]   // London
//let latLong = [40.7128, 74.0059]  // New York
//let latLong = [41.0082, 28.9784]  // Istanbul
//let latLong = [35.6892, 51.3890]  // Tehran
//let latLong = [43.6532, 79.3832]  // Toronto
//let latLong = [37.7749, 122.4194] // San Francisco
var refreshNumbers = false

// Tools
let π = Double .pi
let π2 = 2 * π

// Intro animation
var introFrame = 0.0
let introFrames = 150.0
var easedFrames = 1.0
var introCounter = 0
let introWait = 20
var outroCounter = 0
let outroWait = 10
var animationStage = 0.0
var animationStage1 = 0.0
var animationStage2 = 0.0
var animationStage3 = 0.0
var animationStage4 = 0.0
var animationStage5 = 0.0
var animationStage6 = 0.0
var frameDiff = 149.0
var animationClockRadius = 0.0
var animationDay = 0

// Dates
var now = Date()
var thisCalendar = Calendar.current
var thisTimeZone = thisCalendar.timeZone
var daylightSaving = 1.0
var theseComponents = thisCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: now)
var thisYear = theseComponents.year
var thisMonth = theseComponents.month
var today = theseComponents.day
var thisHour = theseComponents.hour
var thisMinute = theseComponents.minute
var thisSecond = theseComponents.second
var thisNanoSecond = theseComponents.nanosecond
var thisDayOfYear = (thisCalendar as NSCalendar).ordinality(of: .day, in: .year, for: now)
var thisDayOfYearIndex = -1
let daysUntil2015 = 735599
var thisDayOfEra = (thisCalendar as NSCalendar).ordinality(of: .day, in: .era, for: now) - daysUntil2015
let daysInYear = 366
let leapDay = 59
var leapYear = false

let daysInMonths = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
var currentSunRise = 6.0
var currentSunSet = 18.0
let sunRiseSetDuration = 3.0
var sunStage = 0.0
var dayLength = Double(currentSunSet - currentSunRise)
var nightLength = 24.0 - dayLength
let planetOrbitMultipliers = [0.24085387789, 0.61520821147, 1, 1.83056366934, 11.86, 29.46, 84.01, 164.8]
let planetAngularOffset = [π2-2.06, π2-2.4661502, 0, π2-2.325, 0.593412, 2.3841198, π2-1.487021, π2-2.1589723]
let lunarCycle = 27.32
let lunarAngularOffset = -0.9040806
let initialLunarPhase = 0.8
let winterEquinox = 356
let summerEquinox = 173
var count_refresh = 0

// Angles
let toRad = π / 180.0
let toDeg = 180.0 / π
let radUp = π
let radStep = π2 / 24
let dayStep = π2 / Double(daysInYear)
let lunarDayStep = π2 / lunarCycle
let baseAngle = radUp + (dayStep * 11)

var lunarangle = 0.0
var earthangle = 0.0
var lunarphase = 0.5

var clock_quarterVectors = Array(repeating:Array(repeating:CGFloat(), count:4), count:96)
var clock_halfVectors = Array(repeating:Array(repeating:CGFloat(), count:4), count:24)
var clock_wholeVectors = Array(repeating:Array(repeating:CGFloat(), count:4), count:24)
var calendar_dayVectors = Array(repeating:Array(repeating:CGFloat(), count:4), count:366)
var calendar_monthVectors = [CGVector](repeating: CGVector(dx: 0.0, dy: 0.0), count: 12)
var planet_vectors = Array(repeating:Array(repeating:Double(), count:2), count:8)
var lunar_vectors = Array(repeating:Double(), count:2)

// Sizes
var viewBounds = NSRect()
var bgSize = NSSize(width: 0.0, height: 0.0)
var oneWhole = Double(bgSize.height / 40.0)
var oneHalf = Double(oneWhole / 2.0)
var oneTenth = Double(oneWhole / 10.0)
var center = [0.0, 0.0]
var offCenter = [0.0, 0.0]
var clockRadius = 0.0
var innerClockRadius = clockRadius
var quartOffset = 0.0
var planetRadius = 0.0
var planetRadii = [Double](repeating: 0.0, count: 8)
var lunarRadius = 0.0
var lunarOrbitRadius = 0.0
let sdist = Double(149598000) // distance to sun from earth
let earthOblique = toRad * 23.4397; // obliquity of the Earth

var dayTickLength = 0.0
var equinoxOffset = 0.0
var hrTickLength = 0.0
var hlfHrTickLength = 0.0
var quartHrTickLength = 0.0

var dayTickStroke = 0.0
var hrTickStroke = 0.0
var hlfHrTickStroke = 0.0
var quartHrTickStroke = 0.0

var globalScaleModifier = 1.0


// Colours
let whiteColour = NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
var highlightColor = NSColor(red: 0, green: 0.95, blue: 1.0, alpha: 1.0)
var activeColor = NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
var inactiveColor = NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4)
var disabledColor = NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
var bgColorBottom = NSColor(red: 0, green: 0, blue: 0, alpha: 1.0)
var globalAlpha = CGFloat(1.0)

class MoonshineView: ScreenSaverView {
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        self.animationTimeInterval = TimeInterval(1/30)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func startAnimation() {
        super.startAnimation()
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    
    func hasConfigureSheet() -> Bool {
        return false
    }
    
    func configureSheet() -> NSWindow? {
        return nil
    }
    
    func sinDeg(_ degrees: Double) -> Double {
        let radians: Double = degrees * toRad
        return sin(radians)
    }
    func cosDeg(_ degrees: Double) -> Double {
        let radians: Double = degrees * toRad
        return cos(radians)
    }
    func tanDeg(_ degrees: Double) -> Double {
        let radians: Double = degrees * toRad
        return tan(radians)
    }
    func asinDeg(_ value: Double) -> Double {
        return asin(value) * toDeg
    }
    func acosDeg(_ value: Double) -> Double {
        return acos(value) * toDeg
    }
    func atanDeg(_ value: Double) -> Double {
        return atan(value) * toDeg
    }
    func easeInOutCubic(_ t: Double, b: Double, c: Double, d: Double) -> Double {
        var t = t
        t = t / (d/2)
        if (t < 1) {
            return c/2*t*t + b
        }
        t -= 1
        return -c/2 * (t*(t-2) - 1) + b
    }
    func animateVerticalPosition() {
        var radiusModifier = 1.0
        if (thisNanoSecond! > 500000000) {
            radiusModifier = 1.0 + (Double(thisNanoSecond!) / 500000000.0)
        } else {
            radiusModifier = 3.0 - (Double(thisNanoSecond!) / 500000000.0)
        }
        innerClockRadius = innerClockRadius + (3 * radiusModifier) - 9;
        center[1] += (radiusModifier - 2.5)
        offCenter[1] += (radiusModifier - 2.5)
    }
    
    override func draw(_ rect: NSRect) {
        setTime()
        setSizes()
        setAngles()
        setDayLength()
        setSunrise()
        thisDayOfYearIndex = thisDayOfYear
        getMoonIllumination()
        setSunStage()
        setColours()
        drawBackground()
    }
    
    override func animateOneFrame() {
        if (run_intro) {
            incrementIntroAnimation()
            drawOneFrame()
        } else if (run_clock) {
            incrementClock()
            outroCountDown()
            drawOneFrame()
        } else if (run_outro) {
            drawOneFrame()
            incrementOutroAnimation()
        } else {
            introCountDown()
        }
    }
    
    func incrementIntroAnimation() {
        if (introFrame >= introFrames) {
            resetIntro()
        } else {
            self.animationTimeInterval = TimeInterval(1/30)
            easedFrames = easeInOutCubic(introFrame, b: 1.0, c: frameDiff, d: introFrames)
            animationStage = easedFrames / introFrames
            animationStage1 = min(easedFrames / (introFrames / 1.5), 1.0)
            animationStage2 = max(0.0, -0.5 + (animationStage * 1.5))
            animationStage3 = max(0.0, -0.75 + (animationStage * 1.75))
            animationStage4 = max(0.0, -1.0 + (animationStage * 2.0))
            animationStage5 = max(0.0, -2.0 + (animationStage * 3.0))
            animationStage6 = max(0.0, -3.0 + (animationStage * 4.0))
            animationDay = Int(round(366.0 * ((earthangle - radUp) / π2)))
            offCenter[1] = center[1] - (oneWhole * animationStage)
            setAngles()
            introFrame += 1
        }
    }
    
    func incrementClock() {
        setTime()
        if (thisDayOfYearIndex != thisDayOfYear) {
            setDayLength()
            setSunrise()
            thisDayOfYearIndex = thisDayOfYear
        }
        if (refreshNumbers) {
            setAngles()
            getMoonIllumination()
            setSunStage()
            setColours()
        }
    }
    
    func incrementOutroAnimation() {
        if (introFrame <= 0) {
            resetOutro()
        } else {
            self.animationTimeInterval = TimeInterval(1/30)
            introFrame -= 5
            let outroFrames = easeInOutCubic(introFrame, b: 1.0, c: frameDiff, d: introFrames)
            let outroStage = outroFrames / introFrames
            globalAlpha = CGFloat(outroStage)
            globalScaleModifier = 1.0 + (1.0 - outroStage)
            
            now = thisCalendar.date(byAdding: .day, value: 1, to: now)!
            theseComponents = thisCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: now)
            thisYear = theseComponents.year
            thisMonth = theseComponents.month
            today = theseComponents.day
            thisDayOfYear = (thisCalendar as NSCalendar).ordinality(of: .day, in: .year, for: now)
            thisDayOfYear = leapYear || (thisDayOfYear < leapDay) ? thisDayOfYear : thisDayOfYear + 1
            thisDayOfEra = (thisCalendar as NSCalendar).ordinality(of: .day, in: .era, for: now) - daysUntil2015
            
            setSizes()
            setAngles()
            setColours()
        }
    }
    func introCountDown() {
        if (introCounter == introWait) {
            introCounter = 0
            run_intro = true
            run_clock = false
            run_outro = false
        } else {
            introCounter += 1
            drawBackground()
        }
    }
    func outroCountDown() {
        if (outroCounter == outroWait) {
            outroCounter = 0
            run_intro = false
            run_clock = false
            run_outro = true
        } else {
            outroCounter += 1
        }
    }
    
    func resetIntro() {
        self.animationTimeInterval = TimeInterval(5)
        run_intro = false
        run_clock = true
        run_outro = false
    }
    func resetOutro() {
        self.animationTimeInterval = TimeInterval(1/5)
        run_intro = false
        run_clock = false
        run_outro = false
        globalAlpha = 1.0
        globalScaleModifier = 1.0
        introFrame = 0.0
        easedFrames = 1.0
        animationStage = 0.0
        animationStage1 = 0.0
        animationStage2 = 0.0
        animationStage3 = 0.0
        animationStage4 = 0.0
        animationStage5 = 0.0
        animationStage6 = 0.0
        animationClockRadius = 0.0
        animationDay = 0
        setTime()
        setSizes()
        setAngles()
        setColours()
        drawBackground()
    }
    func drawOneFrame() {
        drawBackground()
        drawHoursAndHalves()
        drawQuarterHours()
        drawDayFan()
        drawMonthIndicator()
        drawOrbits()
        drawMoon()
        drawSun()
    }
    
    
    func setColours() {
        let skyStage = sunStage
        let redness = min(1.3 * skyStage, 0.457)
        let highlightRed = CGFloat(0.543 + redness)
        let red = CGFloat(redness + 0.043)
        let disabledRed = red + 0.15
        let inactiveRed = disabledRed + 0.10
        let activeRed = inactiveRed + 0.25
        
        let greenness = min(0.9 * skyStage, 0.784)
        let highlightGreen = CGFloat(0.216 + greenness)
        let green = CGFloat(greenness + 0.016)
        let disabledGreen = green + 0.05
        let inactiveGreen = disabledGreen + 0.03
        let activeGreen = inactiveGreen + 0.10
        
        let highlightBlue = CGFloat(skyStage)
        let blue = CGFloat((skyStage * 0.937) + 0.063)
        let disabledBlue = blue + 0.02
        let inactiveBlue = disabledBlue + 0.02
        let activeBlue = inactiveBlue + 0.10
        
        bgColorBottom = NSColor(red: red, green: green, blue: blue, alpha: 1.0)
        highlightColor = NSColor(red: highlightRed, green: highlightGreen, blue: highlightBlue, alpha: globalAlpha * 1.0)
        activeColor = NSColor(red: activeRed, green: activeGreen, blue: activeBlue, alpha: globalAlpha * 0.7)
        inactiveColor = NSColor(red: inactiveRed, green: inactiveGreen, blue: inactiveBlue, alpha: globalAlpha * 1.0)
        disabledColor = NSColor(red: disabledRed, green: disabledGreen, blue: disabledBlue, alpha: globalAlpha * 1.0)
    }
    
    func setSizes() {
        viewBounds = self.bounds
        bgSize = NSSize(width: NSWidth(viewBounds), height: NSHeight(viewBounds))
        oneWhole = Double(bgSize.height / 50.0) * globalScaleModifier
        oneHalf = Double(oneWhole / 2.0)
        oneTenth = Double(oneWhole / 10.0)
        center = [Double(bgSize.width / 2.0), Double(bgSize.height / 2.0)]
        offCenter = [center[0], center[1] - oneWhole]
        
        clockRadius = oneWhole * 15.0
        innerClockRadius = clockRadius
        quartOffset = oneHalf
        planetRadius = oneWhole * 11.0
        lunarRadius = oneWhole * 2.0
        lunarOrbitRadius = oneTenth * 3
        planetRadii = [oneTenth * 1.3, oneTenth * 1.5, oneTenth * 1.5, oneTenth * 1.4, oneTenth * 3.3, oneTenth * 2.8, oneTenth * 2, oneTenth * 2]
        
        dayTickLength = oneWhole * 2.75
        equinoxOffset = oneTenth * 3.5
        hrTickLength = oneWhole
        hlfHrTickLength = oneHalf
        quartHrTickLength = oneTenth
        
        dayTickStroke = oneTenth
        hrTickStroke = oneTenth
        hlfHrTickStroke = oneTenth
        quartHrTickStroke = oneTenth
    }
    
    func getVectors(_ thisradius: Double, ticklength: Double, angle: Double) -> [CGFloat] {
        let xm = Double(sin(angle))
        let ym = Double(cos(angle))
        let xstart = center[0] + (thisradius * xm)
        let ystart = center[1] + (thisradius * ym)
        let xend = center[0] + ((thisradius + ticklength) * xm)
        let yend = center[1] + ((thisradius + ticklength) * ym)
        return [CGFloat(xstart), CGFloat(ystart), CGFloat(xend), CGFloat(yend)]
    }
    func getOffsetVectors(_ thisradius: Double, ticklength: Double, angle: Double) -> [CGFloat] {
        let xm = Double(sin(angle))
        let ym = Double(cos(angle))
        let xend = center[0] + ((thisradius + ticklength) * xm)
        let yend = center[1] + ((thisradius + ticklength) * ym)
        
        let cangle = atan2((yend - offCenter[1]), (xend - offCenter[0]));
        
        let xstart = offCenter[0] + (thisradius * cos(cangle))
        let ystart = offCenter[1] + (thisradius * sin(cangle))
        
        return [CGFloat(xstart), CGFloat(ystart), CGFloat(xend), CGFloat(yend)]
    }
    func getPoint(_ thisradius: Double, angle: Double, offset: [Double]) -> [Double] {
        let xm: Double = sin(angle)
        let ym: Double = cos(angle)
        let planetX: Double = offset[0] + (thisradius * xm)
        let planetY: Double = offset[1] + (thisradius * ym)
        return [planetX, planetY]
    }
    
    func setAngles() {
        let quartStep = radStep / 4
        var thisClockRadius = clockRadius
        var ticklengthModifier = 1.0
        var angleModifier = radUp
        if (!run_clock) {
            thisClockRadius = max(clockRadius * (introFrames / easedFrames), clockRadius)
            ticklengthModifier = animationStage
            angleModifier = radUp / (introFrames / easedFrames)
        } else {
            animateVerticalPosition()
        }
        for quartHr in 0...95 {
            clock_quarterVectors[quartHr] = getVectors(thisClockRadius - quartOffset, ticklength: quartHrTickLength * ticklengthModifier, angle: angleModifier + (quartStep * Double(quartHr)))
        }
        
        let halfUp = -angleModifier + (radStep / 2)
        for hr in 0...23 {
            let angle = -angleModifier + (radStep * Double(hr))
            let halfAngle = halfUp + (radStep * Double(hr))
            clock_wholeVectors[hr] = getVectors(thisClockRadius, ticklength: hrTickLength * ticklengthModifier, angle: angle)
            clock_halfVectors[hr] = getVectors(thisClockRadius, ticklength: hlfHrTickLength * ticklengthModifier, angle: halfAngle)
        }
        
        var thisDay = 0
        for (index, month) in daysInMonths.enumerated() {
            for dayOfMonth in 1...month {
                let angle = radUp + (dayStep * (Double(thisDay) + 10.0))
                var thisDayTickLength = dayTickLength
                if (thisDay == winterEquinox) {
                    thisDayTickLength -= equinoxOffset
                }
                if (thisDay == summerEquinox) {
                    thisDayTickLength += equinoxOffset
                }
                if (thisDay == leapDay && !leapYear) {
                    thisDayTickLength = thisDayTickLength * 0.95
                }
                
                calendar_dayVectors[thisDay] = getOffsetVectors(planetRadius, ticklength: thisDayTickLength * animationStage2, angle: angle)
                if (dayOfMonth == 1) {
                    calendar_monthVectors.insert(CGVector(dx: Double(calendar_dayVectors[thisDay][2]) - offCenter[0], dy: Double(calendar_dayVectors[thisDay][3]) - offCenter[1]), at: index)
                }
                thisDay += 1
            }
        }
    }
    
    func setTime() {
        now = Date()
        thisCalendar = Calendar.current
        thisCalendar.timeZone = NSTimeZone(name: "Europe/Berlin")! as TimeZone
        thisTimeZone = thisCalendar.timeZone
        daylightSaving = thisTimeZone.daylightSavingTimeOffset()
        daylightSaving = daylightSaving / 60 / 60
        //now = thisCalendar.date(byAdding: .hour, value: 1, to: now)!
        //now = thisCalendar.date(byAdding: .minute, value: 30, to: now)!
        theseComponents = thisCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: now)
        thisYear = theseComponents.year
        leapYear = ((thisYear! % 4 == 0) && (thisYear! % 100 != 0) || (thisYear! % 400 == 0))
        thisMonth = theseComponents.month
        today = theseComponents.day
        thisDayOfYear = (thisCalendar as NSCalendar).ordinality(of: .day, in: .year, for: now)
        thisDayOfYear = leapYear || (thisDayOfYear < leapDay) ? thisDayOfYear : thisDayOfYear + 1
        thisDayOfEra = (thisCalendar as NSCalendar).ordinality(of: .day, in: .era, for: now) - daysUntil2015
        thisHour = theseComponents.hour
        refreshNumbers = (thisMinute != theseComponents.minute)
        thisMinute = theseComponents.minute
        thisSecond = theseComponents.second
        thisNanoSecond = theseComponents.nanosecond
    }
    
    func setDayLength() {
        let latAsRad = latLong[0] * toRad
        let refractionConst = 0.8333
        let revolutionAngle = 0.2163108 + (2 * atan(0.9671396 * tan(0.00860 * (Double(thisDayOfYear) - 186.0))))
        let declinationAngle = asin(0.39795 * cos(revolutionAngle))
        let meridian = sin(refractionConst * toRad) + sin(latAsRad) * sin(declinationAngle)
        let arcOfDay = acos(meridian / (cos(latAsRad) * cos(declinationAngle)))
        dayLength = 24.0 - (24.0 / π) * arcOfDay
        nightLength = 24.0 - dayLength
    }
    
    func setSunrise() {
        let lngHour = latLong[1] / 15.0
        let dayOfYear = Double(thisDayOfYear)
        let zenith = 90.8333
        let localOffset = 1.0 + daylightSaving
        let rise = dayOfYear + ((6.0 - lngHour) / 24.0)
        let meanAnomaly = (0.9856 * rise) - 3.289
        var sunTrueLong = meanAnomaly + (1.916 * sinDeg(meanAnomaly)) + (0.020 * sinDeg(2 * meanAnomaly)) + 282.634
        sunTrueLong = sunTrueLong > 360 ? sunTrueLong - 360 : (sunTrueLong < 0 ? sunTrueLong + 360 : sunTrueLong)
        var rightAscension = atanDeg(0.91764 * tanDeg(sunTrueLong))
        rightAscension = rightAscension > 360 ? rightAscension - 360 : (rightAscension < 0 ? rightAscension + 360 : rightAscension)
        let Lquadrant  = (floor(sunTrueLong/90)) * 90
        let RAquadrant = (floor(rightAscension/90)) * 90
        rightAscension = rightAscension + (Lquadrant - RAquadrant)
        rightAscension = rightAscension / 15
        let sinDec = 0.39782 * sinDeg(sunTrueLong)
        let cosDec = cosDeg(asinDeg(sinDec))
        let cosH = (cosDeg(zenith) - (sinDec * sinDeg(latLong[0]))) / (cosDec * cosDeg(latLong[0]))
        var riseHours = 360 - acosDeg(cosH)
        riseHours = riseHours / 15
        let sunrise = riseHours + rightAscension - (0.06571 * rise) - 6.622
        var UTsunrise = sunrise - lngHour
        UTsunrise = UTsunrise > 24 ? UTsunrise - 24 : (UTsunrise < 0 ? UTsunrise + 24 : UTsunrise)
        currentSunRise = (UTsunrise + localOffset)
        currentSunSet = currentSunRise + dayLength
    }
    
    func setSunStage() {
        let minutesAsDecimal = (1.0 / 60.0) * Double(thisMinute!)
        let currentTimeAsDecimal = Double(thisHour!) + minutesAsDecimal
        if (currentTimeAsDecimal > currentSunRise) {
            if (currentTimeAsDecimal < currentSunRise + sunRiseSetDuration) {
                sunStage = currentTimeAsDecimal - currentSunRise
                sunStage = sunStage * (1 / sunRiseSetDuration)
            } else if (currentTimeAsDecimal > currentSunSet - sunRiseSetDuration) {
                if (currentTimeAsDecimal < currentSunSet) {
                    sunStage = currentTimeAsDecimal - (currentSunSet - sunRiseSetDuration)
                    sunStage = 1 - (sunStage * (1 / sunRiseSetDuration))
                } else {
                    sunStage = 0.0
                }
            } else {
                sunStage = 1.0
            }
        } else {
            sunStage = 0.0
        }
    }
    
    
    
    func getMoonIllumination() {
        let rel_angle_moon = (lunarangle.truncatingRemainder(dividingBy: π2)) / π
        let rel_angle_earth = (earthangle.truncatingRemainder(dividingBy: π2)) / π
        let rel_angle = rel_angle_moon - rel_angle_earth
        let rel_value = rel_angle < -1 ? 2 + rel_angle : (rel_angle > 1 ? rel_angle - 2 : rel_angle)
        lunarphase = 0.5 + (rel_value / 2)
    }
    
    
    
    // Drawing functions
    func drawBackground() {
        bgColorBottom.setFill()
        NSBezierPath.fill(viewBounds)
    }
    
    func drawTick(_ vectors: [CGFloat], tickstroke: Double) {
        let bPath: NSBezierPath = NSBezierPath()
        bPath.move(to: NSMakePoint(vectors[0], vectors[1]))
        bPath.line(to: NSMakePoint(vectors[2], vectors[3]))
        bPath.lineWidth = CGFloat(tickstroke)
        bPath.stroke()
    }
    
    // Draw ticks for clock
    func drawHoursAndHalves() {
        for hr in 0...23 {
            eachHour(hr)
        }
    }
    func eachHour(_ hr:Int) {
        if (hr == 0 && thisHour == 23) {
            if (thisMinute! >= 40) {
                highlightColor.set()
                drawTick(clock_wholeVectors[hr], tickstroke: hrTickStroke)
            }
        } else {
            if (hr == thisHour) {
                if (thisMinute! <= 20) {
                    highlightColor.set()
                    drawTick(clock_wholeVectors[hr], tickstroke: hrTickStroke)
                    if (thisMinute! >= 10) {
                        drawTick(clock_halfVectors[hr], tickstroke: hlfHrTickStroke)
                    } else {
                        disabledColor.set()
                        drawTick(clock_halfVectors[hr], tickstroke: hlfHrTickStroke)
                    }
                } else {
                    if (thisMinute! <= 50) {
                        highlightColor.set()
                        drawTick(clock_halfVectors[hr], tickstroke: hlfHrTickStroke)
                    }
                }
            }
            if (hr > thisHour!) {
                if (hr - 1 == thisHour! && thisMinute! >= 40) {
                    highlightColor.set()
                    drawTick(clock_wholeVectors[hr], tickstroke: hrTickStroke)
                } else {
                    disabledColor.set()
                    drawTick(clock_wholeVectors[hr], tickstroke: hrTickStroke)
                }
                disabledColor.set()
                drawTick(clock_halfVectors[hr], tickstroke: hlfHrTickStroke)
            }
        }
    }
    
    // Draw quarter hour markers that also indicate hours of sunlight
    func drawQuarterHours() {
        for quartHr in 0...95 {
            eachQuarterHour(quartHr)
        }
    }
    func eachQuarterHour(_ quartHr:Int) {
        if (Double(quartHr) >= (currentSunRise * 4) && Double(quartHr) <= (currentSunSet * 4)) {
            activeColor.set()
            drawTick(clock_quarterVectors[quartHr], tickstroke: quartHrTickStroke)
        }
    }
    
    // Draws calendar/day fan
    func drawDayFan() {
        inactiveColor.set()
        var thisDay = 0
        for (index, month) in daysInMonths.enumerated() {
            thisDay = daysEachMonth(thisDay, index: index, month: month)
        }
    }
    func daysEachMonth(_ thisDay: Int, index: Int, month: Int) -> Int {
        var thisDay = thisDay
        for dayOfMonth in 1...month {
            eachDay(thisDay, index: index , dayOfMonth: dayOfMonth)
            thisDay += 1
        }
        return thisDay
    }
    func eachDay(_ thisDay: Int, index: Int, dayOfMonth: Int) {
        if (thisDay == leapDay && !leapYear) {
            disabledColor.set()
        } else if (thisDayOfYear-1 > thisDay && animationDay > (thisDay + 739)) {
            inactiveColor.set()
        } else if (thisDayOfYear-1 == thisDay && animationDay > (thisDay + 739)) {
            highlightColor.set()
        } else {
            disabledColor.set()
        }
        if (thisDay < (animationDay - 366) || run_clock) {
            drawTick(calendar_dayVectors[thisDay], tickstroke: dayTickStroke)
        }
    }
    
    
    // Draws months ring
    func drawMonthIndicator() {
        let thisHighlightColor = highlightColor.withAlphaComponent(CGFloat(animationStage5) * globalAlpha)
        let thisInactiveColor = inactiveColor.withAlphaComponent(CGFloat(animationStage5) * globalAlpha)
        let thisDisabledColor = disabledColor.withAlphaComponent(CGFloat(animationStage5) * globalAlpha)
        let thisRadius = lunarRadius + ((planetRadius - 4 - lunarRadius) * animationStage5)
        let introMonth = Int(round(12.0 * animationStage6))
        let scale = thisRadius / (planetRadius - 4)
        let degreePerDay = 360.0 / Double(daysInYear)
        var endAngle = -90.0 - (degreePerDay * 11.0) + 0.5
        for (index, _) in daysInMonths.enumerated() {
            endAngle = eachMonth(index, thisHighlightColor: thisHighlightColor, thisInactiveColor: thisInactiveColor, thisDisabledColor: thisDisabledColor, thisRadius: thisRadius, introMonth: introMonth, scale: scale, degreePerDay: degreePerDay, endAngle: endAngle)
        }
    }
    func eachMonth(_ index:Int, thisHighlightColor: NSColor, thisInactiveColor:NSColor, thisDisabledColor:NSColor, thisRadius:Double, introMonth:Int, scale:Double, degreePerDay:Double, endAngle:Double) -> Double {
        var endAngle = endAngle
        let endindex = index + 1 < daysInMonths.count ? index + 1 : 0
        let v1 = calendar_monthVectors[index]
        let v2 = calendar_monthVectors[endindex]
        let angle = atan2(v2.dy * CGFloat(scale), v2.dx * CGFloat(scale)) - atan2(v1.dy * CGFloat(scale), v1.dx * CGFloat(scale))
        var deg = Double(angle) * toDeg
        if deg < 0 { deg += 360.0 }
        
        let startAngle = endAngle + deg + 0.5
        
        let radius = CGFloat(thisRadius)
        let arcCenter = NSPoint(x: offCenter[0], y: offCenter[1])
        let path = NSBezierPath()
        path.appendArc(withCenter: arcCenter, radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle))
        path.lineWidth = CGFloat(2) * CGFloat(scale)
        if ((index + 1) == thisMonth && (index + 1 <= introMonth || run_clock)) {
            let thisHighlightColor = highlightColor.withAlphaComponent(CGFloat(animationStage6) * globalAlpha)
            thisHighlightColor.set()
        } else if (index + 1 > thisMonth!) {
            thisDisabledColor.set()
        } else if (index + 1 < thisMonth! && (index + 1 <= introMonth || run_clock)) {
            thisInactiveColor.set()
        } else {
            thisDisabledColor.set()
        }
        path.stroke()
        endAngle = startAngle - 0.5
        return endAngle
    }
    
    
    // draws planet orbits and planets
    func drawOrbits() {
        let multiplier = oneWhole * animationStage5
        let thisHighlightColor = highlightColor.withAlphaComponent(CGFloat(animationStage4) * globalAlpha)
        let thisActiveColor = activeColor.withAlphaComponent(CGFloat(animationStage5) * globalAlpha)
        let thisOrbitColor = activeColor.withAlphaComponent(CGFloat(animationStage3) * globalAlpha)
        let thisInactiveColor = inactiveColor.withAlphaComponent(CGFloat(animationStage4) * globalAlpha)
        let thisDisabledColor = disabledColor.withAlphaComponent(CGFloat(animationStage4) * globalAlpha)
        let thisBgColor = bgColorBottom.withAlphaComponent(CGFloat(animationStage4) * globalAlpha)
        for planet in 0...7 {
            eachPlanet(multiplier, planet: planet, thisHighlightColor: thisHighlightColor, thisActiveColor: thisActiveColor, thisInactiveColor: thisInactiveColor, thisDisabledColor: thisDisabledColor, thisBgColor: thisBgColor, thisOrbitColor: thisOrbitColor)
        }
    }
    func eachPlanet(_ multiplier: Double, planet: Int, thisHighlightColor: NSColor, thisActiveColor: NSColor, thisInactiveColor: NSColor, thisDisabledColor: NSColor, thisBgColor: NSColor, thisOrbitColor: NSColor) {
        let actualPlanetIndex = Int(7 - planet)
        
        let radiusDetract = multiplier * Double(actualPlanetIndex + 1)
        let planetOrbitRadius = lunarRadius + radiusDetract;
        let orbit = NSBezierPath(ovalIn: NSMakeRect(CGFloat(offCenter[0] - planetOrbitRadius), CGFloat(offCenter[1] - planetOrbitRadius), CGFloat(planetOrbitRadius * 2), CGFloat(planetOrbitRadius * 2)))
        
        let planetDayStep = dayStep / planetOrbitMultipliers[actualPlanetIndex]
        let planetFinalAngle = (dayStep * 11) + planetAngularOffset[actualPlanetIndex] + (planetDayStep * Double(thisDayOfEra))
        
        let planetAngle = radUp + (planetFinalAngle * animationStage)
        let xm: Double = sin(planetAngle)
        let ym: Double = cos(planetAngle)
        let planetX: Double = offCenter[0] + (planetOrbitRadius * xm)
        let planetY: Double = offCenter[1] + (planetOrbitRadius * ym)
        let thisPlanetRadius = planetRadii[actualPlanetIndex]
        let planetDisk = NSBezierPath(ovalIn: NSMakeRect(CGFloat(planetX - (thisPlanetRadius / 2)), CGFloat(planetY - (thisPlanetRadius / 2)), CGFloat(thisPlanetRadius), CGFloat(thisPlanetRadius)))
        
        planetDisk.lineWidth = CGFloat(oneTenth * 1.5)
        if (actualPlanetIndex == 2) {
            thisOrbitColor.set()
            orbit.stroke()
            thisBgColor.set()
            planetDisk.stroke()
            popMoonOrbit(planetX, planetY: planetY)
            thisHighlightColor.set()
            planetDisk.fill()
            earthangle = planetAngle
            
            // Draws outline of moon disk
            if (animationStage1 != 1.0) {
                let arcCenter = NSPoint(x: offCenter[0], y: offCenter[1])
                let path = NSBezierPath()
                path.appendArc(withCenter: arcCenter, radius: CGFloat(lunarRadius), startAngle: CGFloat(-90), endAngle: CGFloat(-((planetAngle * toDeg) - 90)), clockwise: true)
                path.lineWidth = CGFloat(oneTenth * 0.5)
                activeColor.set()
                path.stroke()
            }
        } else {
            thisDisabledColor.set()
            orbit.stroke()
            thisBgColor.set()
            planetDisk.stroke()
            thisActiveColor.set()
            planetDisk.fill()
        }
    }
    func popMoonOrbit(_ planetX: Double, planetY: Double) {
        let thisLunarOrbitRadius = lunarOrbitRadius * animationStage6
        let lunarAngle = (baseAngle + lunarAngularOffset) + (lunarDayStep * Double(thisDayOfEra))
        let angleFrameStep = lunarAngle * animationStage
        let lunarxm: Double = sin(angleFrameStep)
        let lunarym: Double = cos(angleFrameStep)
        let lunarX: Double = planetX + (thisLunarOrbitRadius * lunarxm)
        let lunarY: Double = planetY + (thisLunarOrbitRadius * lunarym)
        let lunarDisk = NSBezierPath(ovalIn: NSMakeRect(CGFloat(lunarX - (oneTenth * 0.5)), CGFloat(lunarY - (oneTenth * 0.5)), CGFloat(oneTenth), CGFloat(oneTenth)))
        let lunarOrbit = NSBezierPath(ovalIn: NSMakeRect(CGFloat(planetX - thisLunarOrbitRadius), CGFloat(planetY - thisLunarOrbitRadius), CGFloat(thisLunarOrbitRadius * 2), CGFloat(thisLunarOrbitRadius * 2)))
        bgColorBottom.set()
        lunarOrbit.fill()
        activeColor.set()
        lunarOrbit.stroke()
        bgColorBottom.set()
        lunarDisk.lineWidth = CGFloat(oneTenth * 0.5)
        lunarDisk.stroke()
        highlightColor.set()
        lunarDisk.fill()
        lunarangle = angleFrameStep + π
    }
    
    
    // draws moon crescent
    func drawMoon() {
        if (!run_clock) {
            getMoonIllumination()
        }
        drawCrescent(lunarphase)
    }
    func drawCrescent(_ stage: Double) {
        let disk = NSBezierPath(ovalIn: NSMakeRect(CGFloat(offCenter[0] - lunarRadius), CGFloat(offCenter[1] - lunarRadius), CGFloat(lunarRadius * 2), CGFloat(lunarRadius * 2)))
        var crescentColor = disabledColor.withAlphaComponent(CGFloat(animationStage3) * globalAlpha)
        var diskColor = inactiveColor.withAlphaComponent(CGFloat(animationStage3) * globalAlpha)
        if (run_outro) {
            crescentColor = disabledColor.withAlphaComponent(CGFloat(animationStage) * globalAlpha)
            diskColor = inactiveColor.withAlphaComponent(CGFloat(animationStage) * globalAlpha)
        }
        if (stage == 0.0 || stage == 1.0) {
            diskColor.set()
            disk.fill()
        } else if (stage == 0.5) {
            crescentColor.set()
            disk.fill()
        } else {
            let arcCenter1 = CGPoint(x: offCenter[0], y: offCenter[1])
            let crescent = NSBezierPath()
            let startAngleOuter:CGFloat = 90.0
            let endAngleOuter:CGFloat = 270.0
            
            var angle = CGFloat((.pi / 2) * (stage * 4))
            var angleDeg = angle * CGFloat(toDeg)
            var startAngleInner = endAngleOuter + angleDeg
            var endAngleInner = startAngleOuter - angleDeg
            var xoffset = CGFloat(-lunarRadius) * tan(angle)
            var clockwise1 = true
            crescentColor = disabledColor.withAlphaComponent(CGFloat(animationStage3) * globalAlpha)
            diskColor = inactiveColor.withAlphaComponent(CGFloat(animationStage3) * globalAlpha)
            
            if (stage >= 0.25 && stage < 0.5 || stage >= 0.75) {
                clockwise1 = false
                angle = CGFloat((.pi / 2) * (1 - ((stage.truncatingRemainder(dividingBy: 0.25)) * 4)))
                angleDeg = angle * CGFloat(toDeg)
                startAngleInner = endAngleOuter - angleDeg
                endAngleInner = startAngleOuter + angleDeg
                xoffset = CGFloat(lunarRadius) * tan(angle)
                if (stage < 0.75) {
                    crescentColor = inactiveColor.withAlphaComponent(CGFloat(animationStage3) * globalAlpha)
                    diskColor = disabledColor.withAlphaComponent(CGFloat(animationStage3) * globalAlpha)
                }
            }
            
            if (stage > 0.5 && stage < 0.75) {
                crescentColor = inactiveColor.withAlphaComponent(CGFloat(animationStage3) * globalAlpha)
                diskColor = disabledColor.withAlphaComponent(CGFloat(animationStage3) * globalAlpha)
            }
            
            let clockwise2 = !clockwise1
            let arcCenter2 = CGPoint(x: CGFloat(offCenter[0]) + xoffset, y: CGFloat(offCenter[1]))
            
            crescent.appendArc(withCenter: arcCenter1, radius: CGFloat(lunarRadius), startAngle: startAngleOuter, endAngle: endAngleOuter, clockwise: clockwise1)
            crescent.appendArc(withCenter: arcCenter2, radius: CGFloat(Float(lunarRadius) / cosf(Float(angle))), startAngle: startAngleInner, endAngle: endAngleInner, clockwise: clockwise2)
            crescent.close()
            
            diskColor.set()
            disk.fill()
            crescentColor.set()
            crescent.fill()
        }
    }
    
    
    // draws sun disk
    func drawSun() {
        if (sunStage > 0) {
            var thisSunStage = sunStage
            if (!run_clock) {
                thisSunStage = sunStage * animationStage2
            }
            let diameter = CGFloat(lunarRadius * 2.0)
            let diskOffset = diameter - (diameter * CGFloat(thisSunStage))
            let adjacent = diskOffset / 2.0
            let angle = acos(adjacent / CGFloat(lunarRadius))
            let angleDeg = angle * CGFloat(toDeg)
            let arcCenter1 = CGPoint(x: offCenter[0], y: offCenter[1])
            let arcCenter2 = CGPoint(x: CGFloat(offCenter[0]), y: CGFloat(offCenter[1]) - diskOffset)
            let startAngleOuter:CGFloat = 270.0 + angleDeg
            let endAngleOuter:CGFloat = 270.0 - angleDeg
            
            let startAngleInner:CGFloat = 90.0 + angleDeg
            let endAngleInner:CGFloat = 90.0 - angleDeg
            
            let disk = NSBezierPath()
            disk.appendArc(withCenter: arcCenter1, radius: CGFloat(lunarRadius), startAngle: startAngleOuter, endAngle: endAngleOuter, clockwise: true)
            disk.appendArc(withCenter: arcCenter2, radius: CGFloat(lunarRadius), startAngle: startAngleInner, endAngle: endAngleInner, clockwise: true)
            disk.close()
            
            activeColor.set()
            disk.fill()
        }
    }
    
    func debugText(_ message: String) {
        let font = NSFont(name: "HelveticaNeue-Light", size: 20)
        let string = NSAttributedString(string: String(message), attributes: [
            NSAttributedString.Key.foregroundColor: whiteColour,
            NSAttributedString.Key.kern: 1,
            NSAttributedString.Key.font: font!
            ])
        
        let rect = CGRect(
            x: 200,
            y: 200,
            width: 500,
            height: 200
        )
        
        string.draw(in: rect)
    }
}
