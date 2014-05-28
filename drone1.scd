// Drone track
(
{ { |x|
  var out, base=23+(17*x),
        wobble1, wobble2,
        mulwobble, pulsewobblewobble, pulsewobble, pulsefreq, pulsey,
        cutofffreq, cutoff,pan,panwaver,warblewarble, warble;

  mulwobble = LFCub.ar(freq: 1/(9+x)).exprange(0.1, 1);
  wobble1 = LFCub.ar(1/2, mul:(4+x)/2);
  wobble2 = LFCub.ar(wobble1 + 1/6, mul: mulwobble);

  pulsewobblewobble = LFCub.ar(freq: 1/(38 + (3*x)), mul: 0.3);
  pulsewobble = LFCub.ar(freq: 3 + pulsewobblewobble).range(0.1, 0.9);

  pulsefreq = LFCub.ar(freq: 1/210).range(base*1.8, (base*2.5));

  cutofffreq = LFSaw.ar(freq: 1/(220+(15*x))).exprange(0.5, (860 + (12*x)));
  cutoff = LFSaw.ar(freq: cutofffreq).range(25, (600 + (131*x)));
  pulsey = Pulse.ar(freq: pulsefreq, width: pulsewobble);
  pulsey = MoogFF.ar(pulsey, cutoff);

  warblewarble = LFCub.ar(freq: (5*x)/5).exprange(0.01, 0.4);
  warble = LFCub.ar(freq: warblewarble).range(0.1, 0.9);

  panwaver = SinOsc.ar(freq: 1/(34 + (15*x))).range(0.65, 2.8);
  pan = SinOsc.ar(freq: panwaver, phase: x*13)*0.7;

  out = SinOsc.ar(base + wobble2)*0.5;
  out = out + SinOsc.ar(base*2/3)*0.125;
  out = out + SinOsc.ar((base - wobble2)*16, mul: warble)*0.002;

  out = out.dup + Pan2.ar(pulsey * 0.4, pan);

  Out.ar(0, out);
}!9 }.play
)
