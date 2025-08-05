import themidibus.*;
 import processing.sound.*;
SinOsc sinex;
SinOsc siney;
SinOsc sinez;
SinOsc sinDist;

MidiBus midiBus1; 
MidiBus midiBus2;

float highParam = 0;
float lowParam = 300000;

// Initialization
float x = .001, y = 0, z = 0;  //Start position of attractor (arbitrary)

float listX = 0, listY = 0, listZ = 20; // listener position
float a = 10, b = 28, c = 8.0 / 3.0; //Parameters of attractor (suggested by Lorenz)
 
// ArrayList of PVector objects to store
// the position vectors of the points to be plotted.
ArrayList<PVector> points = new ArrayList<PVector>();

int n;//counts iterations of program

int currentToneStart = 0; 
 
Note note1 = null;
Note note2 = null;
     
void setup()
{
    // Creating the output window
    // and setting up the OPENGL renderer
    //size(1080, 720, P3D);
 
    // Configure Midi Buses
    //print(MidiBus.availableOutputs()); // List all available Midi devices on STDOUT. This will show each device's index and name.
    midiBus1 = new MidiBus(this, -1, "DP Input"); 
    midiBus2 = new MidiBus(this, -1, "DP Input 2"); 
 
    // listener position - comment out for real world use
    points.add(new PVector(listX, listY, listZ));
}
  
void beep(SinOsc osc) 
{
 osc.play(); 
} 

void stopBeep(SinOsc osc)
{ 
  osc.stop();  
}
 
void draw()
{
    int intervalInMilliseconds = 600;
    int durationInMilliseconds = 550;
    int velocity = 70;
    
    background(0);
 
    // Implementation of the differential equations 
    float dt = 0.01; //timestep (sort of aribtrary)
    float dx = (a * (y - x)) * dt;
    float dy = (x * (b - z) - y) * dt;
    float dz = (x * y - c * z) * dt;
    x += dx;
    y += dy;
    z += dz;
    
    n++;
    
    //println(n+": "+x+", "+y+", "+z);
   
    int millisecs = millis();
     
    int stopTimeMilliseconds = currentToneStart + durationInMilliseconds;
    if (millisecs > stopTimeMilliseconds)
    {
        if (note1 != null) stopNote(note1, midiBus1);
        if (note2 != null) stopNote(note2, midiBus2);      
    }
      
   
   if (millisecs > intervalInMilliseconds + currentToneStart)
   {           
   
     float dist= sqrt(pow(x - listX, 2) + pow(y - listY,2) + pow(z - listZ,2));
     int intMidiNoteValue = normalizeToRange(dist, .825, 33.34, 42, 100);

     note2 = playNote(1, intMidiNoteValue, velocity, midiBus2);

     println ("dist: " + dist);
     println ("intMidiNote: " + intMidiNoteValue);
     
     // helpers to help determine range of distances for scaling (normalizeToRange)
     if (dist > highParam)
       highParam = dist;

     if (dist < lowParam)
       lowParam = dist;

      currentToneStart = millisecs;
    }  
}

void keyPressed(){
    println("Low Param: " + lowParam);
    println("High Param: " + highParam);

    this.exit();
}

Note playNote(int channel, int pitch, int velocity, MidiBus midiBus)
{
  Note note; 
  note = new Note(channel, pitch, velocity);
  
  midiBus.sendNoteOn(note);
  //myBus.sendControllerChange(channel, number, value); // Send a controllerChange
  
  return note;
}

void stopNote(Note note, MidiBus midiBus)
{
  midiBus.sendNoteOff(note);
}

float normalizeToRange(float param, float lowParam, float highParam, float lowRange, float highRange)
{
   float rtn = param;
   
   float pctPlaceInRange  = (param  - lowParam)/ (highParam - lowParam);
   rtn = ((highRange - lowRange) * pctPlaceInRange) + lowRange;
   
   return rtn; 
}

int normalizeToRange(float param, float lowParam, float highParam, int lowRange, int highRange)
{
   float rtn = param;
   //map(value, low, high, 0, 1).
   float pctPlaceInRange  = (param  - lowParam)/ (highParam - lowParam); 
   rtn = ((highRange - lowRange) * pctPlaceInRange) + lowRange;
   
   return round(rtn); 
}



void logNoteOn(int channel, int pitch, int velocity) {
  // Receive a noteOn
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
}

void logNoteOff(int channel, int pitch, int velocity) {
  // Receive a noteOff
  println();
  println("Note Off:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
}

void logControllerChange(int channel, int number, int value) {
  // Receive a controllerChange
  println();
  println("Controller Change:");
  println("--------");
  println("Channel:"+channel);
  println("Number:"+number);
  println("Value:"+value);
}

void delay(int time) {
  int current = millis();
  while (millis () < current+time) Thread.yield();
}
