SynthDef(\default,
{ arg i_out, freq = 440, gate = 1, amp = 1;
  var o1, env0;
  env0 = EnvGen.kr(Env.perc(0.01, 0.9), doneAction: 2);
  o1 =  SinOsc.ar(freq,0,env0) *0.5 * amp;
  o1 = o1 + Klang.ar(`[ Array.rand(7, freq, freq*4), nil, nil ], 1, 0) * 0.07 * amp * env0;
  Out.ar(i_out, Pan2.ar(o1, 0));
}
).store;

x = Routine {
  var notes = Pseq(#[[0, 1], [0, 0.5], [6, 0.5], [4, 1], [ 0, 0.5], [4, 0.5 ]], 4).asStream;
  var root = 85;
  while { v = notes.next; v.notNil } { // get next note/duration
      t = 0; // cumulative time
    l = v[1]; // duration
    k = Pgauss(midicps(root + v[0]), 1, inf).asStream; // gaussian distributed stream of with median at note
    d = Pgeom(l/3, 0.61803398874985, inf).asStream; // reducing duration (uses golden ratio)
      e = Pgeom(1.0, 0.75, inf).asStream; // reducing amplitude
    while { t < l } {
        b = d.next;
    if ((t + b) > l, { b = l - t; }); // reached timeout
    if (b < 0.005, { b = l - t; }); // to low duration, so play silence after this
        ( \freq: k.next, \dur: b, \amp: e.next ).yield;
    t =  t + b;
     }
  };
};
Pseq([x], 1).play;
