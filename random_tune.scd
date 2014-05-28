// Randomised tune
(
Tempo.bpm = 148;
SynthDef("rest", { }).send(s);

SynthDef("siney",
{ arg i_out, freq = 360, gate = 1;
  var o1, env0;
  env0 = EnvGen.kr(Env.adsr,gate, doneAction:2);
  o1 =  SinOsc.ar(freq,0,env0) *0.3;
  Out.ar(i_out, Pan2.ar(o1, 0));
}
).send(s);

SynthDef("basey",
{ arg i_out, freq = 160, gate = 1, sustain = 0.2;
  var o1, env0, pwobble;
  pwobble = SinOsc.kr(SinOsc.kr(0.2, 0, 3, 3), 0, 10, 10);
  env0 = EnvGen.kr(Env.adsr,gate);
  o1 =  LFSaw.ar(freq + pwobble,0,env0) *0.6;
  // Out.ar(i_out, LPF.ar(Pan2.ar(o1, 0),  EnvGen.ar(Env.new([3000, 1500, 50], [0.05, 0.2], [-4, -5]), doneAction:2)));
  Out.ar(i_out, LPF.ar(Pan2.ar(o1, 0),  EnvGen.ar(Env.new([3000, 1500, 50], [0.20, 0.8]*sustain, [-4, -5]), doneAction:2)));
}
).send(s);

SynthDef("kick",
{ arg outBus=0;
  var env0, env1, env1m, out;
         
  env0 =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), doneAction:2);
  env1 = EnvGen.ar(Env.new([110, 59, 29], [0.005, 0.29], [-4, -5]));
  env1m = env1.midicps;
         
  out = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
  out = out + ( WhiteNoise.ar(1) * 10.5);
  out = LPF.ar(out, env1m*1.5, env0);
  out = out + SinOsc.ar(env1m, 0.5, env0);
         
  out = out.clip2(0.8);
    
  Out.ar(outBus, out.dup);
}).send(s);

SynthDef("clap",
{ arg outBus=0;
  var env0, env1, env1m, out;
         
  env0 =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), doneAction:2);
  env1 = EnvGen.ar(Env.new([900, 720, 360], [0.005, 0.1], [-4, -5]));
  env1m = env1.midicps;
         
  out = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
  out = out * ( WhiteNoise.ar(1) * 10.5);
  out = LPF.ar(out, env1m*1.0, env0);
  out = (out + SinOsc.ar(env1m, 0.5, env0))*0.2;
         
  out = out.clip2(0.8);
  out = GVerb.ar(out, 10, 0.1, 0.7, mul: 0.3);
    
  Out.ar(outBus, out.dup);
}).send(s);

SynthDef("hihat",
{ arg out=0,isOpen=0,amp;
  var env0, env1, env1m, outb;

  isOpen.postln;

  env0 =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.006 + (isOpen*0.1), 0.06 + (isOpen*0.2)], [-4, -2, -4]), doneAction:2);

  outb = WhiteNoise.ar(1) * env0 * 0.2;

  outb = outb.clip2(0.8);
    
  Out.ar(out, outb.dup);
}).send(s);

c = Pbind(
  \instrument, \siney,
  \dur, Pwrand([1, 0.5, 0.25, 1/3], [ 0.55, 0.25, 0.1, 0.1 ], inf),
  \degree, Pwrand((0..7), [0.35, 0.08, 0.15, 0.08, 0.22, 0.07, 0.05], inf)
);

d = Pbind(
  \instrument, Pwrand([\basey, \rest], [0.8, 0.2], inf),
  \dur, Pwrand([ Pseq([ 1 ]), Pseq([ 0.5, 0.5 ]), Pseq([1/3, 1/3, 1/3] ) ], [ 0.2, 0.65, 0.15 ], inf),
  \degree, Pwrand((0..7), [0.35, 0.08, 0.15, 0.08, 0.22, 0.07, 0.05], inf),
  \octave,3
  );

e = Pbind(
  \instrument, \siney,
  \dur, Pwrand([4, 2, 1], [ 0.6, 0.3, 0.1 ], inf),
  \degree, Pwrand((0..7), [0.35, 0.08, 0.15, 0.08, 0.22, 0.07, 0.05], inf),
  \octave,6
  );

n = Pbind(
  \instrument, Pseq([Pseq([\kick]), Pwrand([\kick, \clap, \rest], [0.65, 0.25, 0.1], 3) ], inf),
  \dur, Pwrand([ Pseq([ 1 ]), Pseq([ 0.5, 0.5 ]), Pseq([1/3, 1/3, 1/3] ) ], [ 0.7, 0.25, 0.05 ], inf),
  \degree, 0, \octave,2
  );

o = Pbind(
  \instrument, \hihat,
  \dur,Pseq([0.5,0.5,1],inf), // note duration
  \amp,Pseq([0.8,0.6,0.9],inf),
  \isOpen,Pseq([0,0,1.0],inf),
  \octave,2
  );

z = Ppar([c,d, n, o]).play();
)
