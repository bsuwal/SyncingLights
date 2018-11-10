#include <Keyboard.h>

#include <FastLED.h>

#define LED_PIN     8
#define NUM_LEDS    400
#define BRIGHTNESS  64
#define LED_TYPE    WS2811
#define COLOR_ORDER GRB
#define NUM_BYTES   6
#define K           0.5
#define N           0.9
CRGB leds[NUM_LEDS];

byte bytes[NUM_BYTES];

uint8_t brightness = 255;

CRGBPalette16 currentPalette;
TBlendType    currentBlending;

extern CRGBPalette16 myRedWhiteBluePalette;
extern const TProgmemPalette16 myRedWhiteBluePalette_p PROGMEM;


uint8_t bps = 0; // bytes per second


void setup() {
  delay( 3000 ); // power-up safety delay
  FastLED.addLeds<LED_TYPE, LED_PIN, COLOR_ORDER>(leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.setBrightness(  BRIGHTNESS );
  Serial.begin(9600);

  //{CRGB::Red, CRGB::Gray, CRGB::Blue,CRGB::Black,
    //currentPalette = RainbowColors_p;
      currentPalette = CRGBPalette16(
                     CRGB::Red, CRGB::Green,   CRGB::Blue, CRGB::White,
                     CRGB::Red, CRGB::Green,  CRGB::Blue,  CRGB::Black,
                     CRGB::Red,  CRGB::Green,   CRGB::Blue, CRGB::White,
                     CRGB::Red, CRGB::Green,  CRGB::Blue,  CRGB::Black );
    currentBlending = NOBLEND;
}


void loop()
{

  if (Serial.available() >= NUM_BYTES) // if there is data to read
  {
    Serial.readBytes(bytes, NUM_BYTES);
    bps = bytes[0];
    bps = 3 * bps;
  }
  static uint8_t startIndex = 0;
  static long long lastUpdate = 0;
  static uint8_t r = 0;

  
  if (millis() - lastUpdate >= 1000 / (bps + 5)) { //
  //if (millis() - lastUpdate >= 1) {
    lastUpdate = millis();
    startIndex = startIndex + 1; /* motion speed */ 
  } 
  ChangePalette(bytes);
  FillLEDsFromPaletteColors( startIndex);
  FastLED.show();
}

uint8_t average(byte bytes[])
{
  int avg = 0;
  for (int i = 1; i < NUM_BYTES; i++) {
    avg += bytes[i];
  }
  avg = avg/(NUM_BYTES - 1);
  if (avg > 255) {
    avg = 255;
  }
  return (uint8_t) avg;
}

void ChangePalette(byte bytes[])
{
    brightness = K * average(bytes) + N * bytes[1];
    //brightness = bytes[1];
}

void FillLEDsFromPaletteColors( uint8_t colorIndex)
{
  //brightness = 255;
  

  for ( int i = 0; i < NUM_LEDS; i++) {
    leds[i] = ColorFromPalette( currentPalette, colorIndex, brightness, currentBlending);
    colorIndex += 3;
  }
}


// There are several different palettes of colors demonstrated here.
//
// FastLED provides several 'preset' palettes: RainbowColors_p, RainbowStripeColors_p,
// OceanColors_p, CloudColors_p, LavaColors_p, ForestColors_p, and PartyColors_p.
//
// Additionally, you can manually define your own color palettes, or you can write
// code that creates color palettes on the fly.  All are shown here.

//void ChangePalettePeriodically(uint8_t red, uint8_t blue)
//{
//    uint8_t secondHand = (millis() / 1000) % 60;
//    static uint8_t lastSecond = 0;
//
//
//    //int redThres[4] = {50, 150, 200, 250}
//
//
//        lastSecond = secondHand;
//        if (red <= 100 && blue <= 25) {
//          currentPalette = RainbowStripeColors_p;   currentBlending = NOBLEND;
//        }
//        if (red <= 100 && blue > 25) {
//          SetupPurpleAndGreenPalette();  currentBlending = NOBLEND;
//        }
//        else if (red <= 200 && red > 100 && blue <= 25 ) {
//          currentPalette = PartyColors_p;           currentBlending = NOBLEND;
//        }
//        else if (red <= 200 && red > 100 && blue > 25 ) {
//          currentPalette = myRedWhiteBluePalette_p; currentBlending = NOBLEND;
//        }
//        else if (blue >= 10) {
//          currentPalette = CloudColors_p;           currentBlending = NOBLEND;
//        }
//        else
//        {
//          currentPalette = RainbowColors_p;         currentBlending = LINEARBLEND;
//        }
//
//
//    /*
//    if( lastSecond != secondHand) {
//        lastSecond = secondHand;
//        if( secondHand ==  0)  { currentPalette = RainbowColors_p;         currentBlending = LINEARBLEND; }
//        if( secondHand == 10)  { currentPalette = RainbowStripeColors_p;   currentBlending = NOBLEND;  }
//        if( secondHand == 15)  { currentPalette = RainbowStripeColors_p;   currentBlending = LINEARBLEND; }
//        if( secondHand == 20)  { SetupPurpleAndGreenPalette();             currentBlending = LINEARBLEND; }
//        if( secondHand == 25)  { SetupTotallyRandomPalette();              currentBlending = LINEARBLEND; }
//        if( secondHand == 30)  { SetupBlackAndWhiteStripedPalette();       currentBlending = NOBLEND; }
//        if( secondHand == 35)  { SetupBlackAndWhiteStripedPalette();       currentBlending = LINEARBLEND; }
//        if( secondHand == 40)  { currentPalette = CloudColors_p;           currentBlending = LINEARBLEND; }
//        if( secondHand == 45)  { currentPalette = PartyColors_p;           currentBlending = LINEARBLEND; }
//        if( secondHand == 50)  { currentPalette = myRedWhiteBluePalette_p; currentBlending = NOBLEND;  }
//        if( secondHand == 55)  { currentPalette = myRedWhiteBluePalette_p; currentBlending = LINEARBLEND; }
//    }*/
//}

// This function fills the palette with totally random colors.
void SetupTotallyRandomPalette()
{
  for ( int i = 0; i < 16; i++) {
    currentPalette[i] = CHSV( random8(), 255, random8());
  }
}

// This function sets up a palette of black and white stripes,
// using code.  Since the palette is effectively an array of
// sixteen CRGB colors, the various fill_* functions can be used
// to set them up.
void SetupBlackAndWhiteStripedPalette()
{
  // 'black out' all 16 palette entries...
  fill_solid( currentPalette, 16, CRGB::Black);
  // and set every fourth one to white.
  currentPalette[0] = CRGB::White;
  currentPalette[4] = CRGB::White;
  currentPalette[8] = CRGB::White;
  currentPalette[12] = CRGB::White;

}

// This function sets up a palette of purple and green stripes.
void SetupPurpleAndGreenPalette()
{
  CRGB purple = CHSV( HUE_PURPLE, 255, 255);
  CRGB green  = CHSV( HUE_GREEN, 255, 255);
  CRGB black  = CRGB::Black;

  currentPalette = CRGBPalette16(
                     green,  green,  black,  black,
                     purple, purple, black,  black,
                     green,  green,  black,  black,
                     purple, purple, black,  black );
}


// This example shows how to set up a static color palette
// which is stored in PROGMEM (flash), which is almost always more
// plentiful than RAM.  A static PROGMEM palette like this
// takes up 64 bytes of flash.
const TProgmemPalette16 myRedWhiteBluePalette_p PROGMEM =
{
  CRGB::Red,
  CRGB::Gray, // 'white' is too bright compared to red and blue
  CRGB::Blue,
  CRGB::Black,

  CRGB::Red,
  CRGB::Gray,
  CRGB::Blue,
  CRGB::Black,

  CRGB::Red,
  CRGB::Red,
  CRGB::Gray,
  CRGB::Gray,
  CRGB::Blue,
  CRGB::Blue,
  CRGB::Black,
  CRGB::Black
};



// Additionl notes on FastLED compact palettes:
//
// Normally, in computer graphics, the palette (or "color lookup table")
// has 256 entries, each containing a specific 24-bit RGB color.  You can then
// index into the color palette using a simple 8-bit (one byte) value.
// A 256-entry color palette takes up 768 bytes of RAM, which on Arduino
// is quite possibly "too many" bytes.
//
// FastLED does offer traditional 256-element palettes, for setups that
// can afford the 768-byte cost in RAM.
//
// However, FastLED also offers a compact alternative.  FastLED offers
// palettes that store 16 distinct entries, but can be accessed AS IF
// they actually have 256 entries; this is accomplished by interpolating
// between the 16 explicit entries to create fifteen intermediate palette
// entries between each pair.
//
// So for example, if you set the first two explicit entries of a compact
// palette to Green (0,255,0) and Blue (0,0,255), and then retrieved
// the first sixteen entries from the virtual palette (of 256), you'd get
// Green, followed by a smooth gradient from green-to-blue, and then Blue.
