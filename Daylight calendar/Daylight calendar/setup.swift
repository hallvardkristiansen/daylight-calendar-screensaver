import AppKit
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
let daysUntil2018 = 736695
var thisDayOfEra = (thisCalendar as NSCalendar).ordinality(of: .day, in: .era, for: now) - daysUntil2018
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
let planetAngularOffset = [1.5708, π-0.0977384, 0, 1.32645, 2.0, π-0.00872665, -1.4, -1.9]
let lunarCycle = 27.32
let lunarAngularOffset = 0.0
let initialLunarPhase = 1.0
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

