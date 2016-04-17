(
​
s.waitForBoot{

	​
     {s.sync;
		b = Buffer.read(s, "/home/alex/Desktop/Recording of Sirens from Ulysses_Cathy Berberian.wav");
		5.wait;
		SynthDef(\myPlayBuf, {| out = 0, bufnum = 0, amp = 0.5 |
			Out.ar(out,PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), loop: 1.0).dup * amp)
		}).play(s, [\out, 0, \bufnum, b]);
	}.fork;
	​
	​
	{s.sync;
		~buffer = Buffer.read(s, "/home/alex/Desktop/Recording of Sirens from Ulysses_Cathy Berberian_Evil_Mode.wav");
		~stream = Pseries(1, 0.01, inf).asStream;
		​
		5.wait;
		~synth = SynthDef(\myPlayBuf2, { | out = 0, trigger = 0, amp = 2 |
			var env, source;
			source = PlayBuf.ar(2, ~buffer.bufnum, BufRateScale.kr(~buffer.bufnum), loop: 1.0);
			env = EnvGen.kr(
				Env.new([ 0.001, 1, 0.5, 0 ], [ 0.01, 0.3, 8 ], -4, 2, nil),
				Changed.kr (trigger)
			);
			Out.ar(out, (env * source * amp));
		}).play;
		​
		​
		​
		OSCdef.new(
			\bang,
			{
				arg msg, time, addr, port;
				[msg, time, addr, port].postln;
				~synth.set(\trigger, ~stream.next);
			}, '/bang'
		)
	}.fork;

	{s.sync;
		SynthDef.new(\noise, {
			arg freq=440, amp=0.2, pha = 0;
			var sig, env, sig2, gen;

			sig=SinOsc.ar (freq, 0.05);
			sig2=LFTri.ar (freq, 0.08) ;
			env = Env.triangle(4, amp);
			gen = EnvGen.kr(env, doneAction: 2);

			sig=[sig+sig2]*gen;
			Out.ar(0,(sig * amp).dup);

		}).play;
		5.wait;

		OSCdef.new(
			\bangbang,
			{
				arg msg, time, addr, port;
				[msg, time, addr, port].postln;

				Synth(\noise, [freq:msg[1] * (rrand(100, 2000))]);
				Synth(\noise, [pha:msg[1] * (rrand(0.1, 1))]);
			},'/bang'
		)
	}.fork;



	{s.sync;
		SynthDef.new(\waves, {
			arg freq=440, amp=0.3;
			var sig, env, sig2, sig3, gen;

			sig=GrayNoise.ar (0.06);
			sig2=LFNoise2.ar (freq, 0.1);
			sig3=LFNoise1.ar(freq, amp);
			env = Env.triangle(4, 1);
			gen = EnvGen.kr(env, doneAction: 2);

			sig=[sig+sig2+sig3]*gen;
			Out.ar(0,(sig * amp).dup);

		}).play;
		5.wait;


		OSCdef.new(
			\bangbangbang,
			{
				arg msg, time, addr, port;
				[msg, time, addr, port].postln;
				Synth(\waves, [gate:msg[1]]);
			},'/bang'
		)
	}.fork;

}
)


