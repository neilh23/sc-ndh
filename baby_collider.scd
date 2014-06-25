// Sounds to soothe a baby 

x = SynthDef("heart",
{ arg outBus=0;
  var env0, env1, env1m, out;
         
  env0 =  EnvGen.ar(Env.new([1.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), doneAction:2);
  env1 = EnvGen.ar(Env.new([15, 47, 23], [0.005, 0.29], [-4, -5]));
  env1m = env1.midicps;
         
  out = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
  out = out + ( WhiteNoise.ar(1) * 7.5);
  out = LPF.ar(out, env1m*1.5, env0);
  out = out + SinOsc.ar(env1m, 0.5, env0);
         
  out = out.clip2(0.8);
  out = FreeVerb.ar(out, 0.4, 0.6, 0.4);
  out = BLowPass.ar(out, 210);
  Out.ar(outBus, out.dup);
});

Routine.run({inf.do( { x.play; (0.1 + rand(0.05)).wait; x.play; (0.85 + rand(0.12)).wait; } )})
