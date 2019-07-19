const int PIN_VALVE_OUTPUT = 5;
const int PIN_LICK_TRIAL_KEY_OUTPUT = 6;
const int PIN_LICK_TDT_OUTPUT = 7;

const int PIN_CONTROL_LICK_INPUT = 8; // previously Valve Inhibit
const int PIN_MANUAL_LICK_INPUT = 9;
const int PIN_TEST_INPUT = 10;
const int PIN_LICKPIN_INPUT = 11;

const int PIN_POWER_ON_OUTPUT = 12;
const int PIN_VALVE_ON_OUTPUT = 13;

bool Lick_trial = false;
bool isLickIRBlocked = true;
bool isManualButtonPushed = false;

unsigned long currentT = 0;
unsigned long maxlick = 6000;
unsigned long flick = 0;
unsigned long suppress = 3000;

void setup() 
{ 
  pinMode(PIN_TEST_INPUT, INPUT);
  pinMode(PIN_VALVE_OUTPUT, OUTPUT);
  pinMode(PIN_LICKPIN_INPUT, INPUT);
  pinMode(PIN_LICK_TDT_OUTPUT, OUTPUT); 
  pinMode(PIN_LICK_TRIAL_KEY_OUTPUT, OUTPUT);
  pinMode(PIN_CONTROL_LICK_INPUT, INPUT);
  pinMode(PIN_MANUAL_LICK_INPUT, INPUT); 
  pinMode(PIN_POWER_ON_OUTPUT, OUTPUT);
  pinMode(PIN_VALVE_ON_OUTPUT,OUTPUT);

  digitalWrite(PIN_POWER_ON_OUTPUT, HIGH);
}


void loop() 
{
  currentT = millis();

  isLickIRBlocked = !digitalRead(PIN_LICKPIN_INPUT);
  isManualButtonPushed = digitalRead(PIN_TEST_INPUT) || digitalRead(PIN_CONTROL_LICK_INPUT);


  if (isLickIRBlocked) // sensor blocked = licking
  { 
    digitalWrite(PIN_LICK_TDT_OUTPUT, HIGH);
    digitalWrite(PIN_VALVE_OUTPUT, HIGH);
    digitalWrite(PIN_VALVE_ON_OUTPUT,HIGH);
    digitalWrite(PIN_LICK_TRIAL_KEY_OUTPUT,HIGH);
  }
  else // sensor not blocked = not licking
  { 
    digitalWrite(PIN_LICK_TDT_OUTPUT, LOW);
    digitalWrite(PIN_LICK_TRIAL_KEY_OUTPUT, LOW);
    digitalWrite(PIN_VALVE_OUTPUT, LOW);

    if (isManualButtonPushed || digitalRead(PIN_MANUAL_LICK_INPUT))
    { 
      digitalWrite(PIN_VALVE_OUTPUT, HIGH);
      digitalWrite(PIN_VALVE_ON_OUTPUT,HIGH);
    }
    else
    { 
      digitalWrite(PIN_VALVE_OUTPUT, LOW);
      digitalWrite(PIN_VALVE_ON_OUTPUT,LOW);
    }
  }
}
