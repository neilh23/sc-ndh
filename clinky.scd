(
SynthDef(\default,
  { arg i_out, freq = 440, gate = 1, amp = 1, pan = 0;
    var o1, env0, env1;
    env0 = EnvGen.kr(Env.perc(0.01, 0.6), doneAction: 2);
    env1 = EnvGen.kr(Env.adsr(0.2, 0.5), doneAction: 2);
    o1 =  SinOsc.ar(freq,0,env1) *0.6 * amp;
    o1 = o1 + SinOsc.ar(freq/2,0,env1) *0.7 * amp;
    o1 = o1 + Klang.ar(`[ Array.rand(5, freq, freq*3), nil, nil ], 1, 0) * 0.07 * amp * env0;
    Out.ar(i_out, Pan2.ar(o1, pan));
  }
).store;

x = Routine {
  var notes = Pseq(#[[0, 0.5], [4, 0.5], [ 5, 0.25], [ 5, 0.25], [4, 0.5 ], [ 5, 0.25 ], [ 4, 0.5 ], [ 2, 0.5 ], [0, 0.5], [ 0, 0.25 ] ], 1).asStream;
  var root = 85;
  while { v = notes.next; v.notNil } { // get next note/duration
    t = 0; // cumulative time
    l = v[1]; // duration
    //  ((Pgauss(0, 0.5, 15)*Pseries(0,1,inf)) + 100).asStream.nextN(15).plot;
    k =  ((Pgauss(0, 0.5, 15)*Pseries(0,10,inf)) + midicps(root + v[0])).asStream;
    d = Pgeom(l/3, 0.61803398874985, inf).asStream; // reducing duration (uses golden ratio)
    e = Pgeom(1.0, 0.75, inf).asStream; // reducing amplitude
    p = (Pseries(0, 0.2)*Pshuf(#[-1, 1],inf)).collect({|x| min(1, max(-1, x))}).asStream;
    while { t < l } {
      b = d.next;
      if ((t + b) > l, { b = l - t; }); // reached timeout
      if (b < 0.005, { b = l - t; }); // to low duration, so play silence after this
      ( \freq: k.next, \dur: b, \amp: e.next, \pan: p.next ).yield;
      t =  t + b;
    }
  };
};
TempoClock.default.tempo = 35/60;
Pseq([x], 1).play;
)
