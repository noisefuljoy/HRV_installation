// impulse
Ndef(\impulse_rhythm, {
	var sig = Trig.ar(Impulse.ar(0.4, 0, 0.5), 0.5);
	sig = sig * LPF.ar(Impulse.ar(SinOsc.kr(1.0).range(300.0,80000.0)), SinOsc.kr(LFNoise1.kr(0.8).range(0.1,32.8)).range(200, 8000.0));
	//sig = CombC.ar(sig, 0.2, SinOsc.kr(LFNoise0.kr(0.4).range(0.1,30.0)).range(0.001,0.01),SinOsc.kr(3).range(5, 15), 0.2, sig * 0.8 );
	//sig = FreeVerb.ar(sig, 0.4, 0.8);
	sig = sig ! 2;
}).play;

/*channel 1 */
Ndef(\impulse_rhythm, {
	var sig = Trig.ar(Impulse.ar(0.4, 0, 0.5), 0.5);
	sig = sig * LPF.ar(Impulse.ar(SinOsc.kr(1.0).range(300.0,80000.0)), SinOsc.kr(LFNoise1.kr(0.8).range(0.1,32.8)).range(200, 8000.0));
	//sig = CombC.ar(sig, 0.2, SinOsc.kr(LFNoise0.kr(0.4).range(0.1,30.0)).range(0.001,0.01),SinOsc.kr(3).range(5, 15), 0.2, sig * 0.8 );
	//sig = FreeVerb.ar(sig, 0.4, 0.8);
	Out.ar(0, sig);
}).play;

Ndef(\impulse_rhythm2, {
	var sig = Trig.ar(Impulse.ar(0.45, 0, 0.5), 0.5);
	sig = sig * LPF.ar(Impulse.ar(SinOsc.kr(1.0).range(200.0,30000.0)), SinOsc.kr(LFNoise1.kr(0.8).range(0.1,32.8)).range(200, 8000.0));
	//sig = CombC.ar(sig, 0.2, SinOsc.kr(LFNoise0.kr(0.4).range(0.1,30.0)).range(0.001,0.01),SinOsc.kr(3).range(5, 15), 0.2, sig * 0.8 );
	//sig = FreeVerb.ar(sig, 0.4, 0.8);
	Out.ar(1, sig);
}).play;

//harpsipluck
SynthDef(\harpsichord_pluck, {
	|out=0 amp=0.1, freq=440, pan=0, atk=0, rel=0, trig= 1, maxdelaytime= 0.2, decaytime= 0.05, coef= 0.1|
	var env, sig, delay;
	env = EnvGen.kr(Env.linen(atk, decaytime, rel), doneAction: Done.freeSelf);
	sig = PinkNoise.ar(amp); //Can use white noise here, but Pink is more realistic
	delay = freq.reciprocal;
	sig = Pluck.ar(sig, trig, maxdelaytime , delay , decaytime , coef ) //fundamental
	+ Pluck.ar(sig, trig, maxdelaytime , delay/2 , decaytime , coef ); //octave higher
	/*Out.ar(0, Pan2.ar(sig , pan))*/
	Out.ar(out, sig!2);
}).store;

s = ScalaTunings.at('cet97');
s = Tuning.at('cet97');
b = Scale.new((0..11), 12, s, "cet97");

Pdef(\t, Pbind(\instrument, \harpsichord_pluck, \dur, Pseq([ 0.075, 1.0 ],inf),
	\decaytime, Pwhite(0.0001, 4.15),
	\degree, Pseq([0,1,2,3,4,20,21, 31, 12, 13, 29,4, 5], inf),
	\octave, Prand([5,6],inf), \scale, b, \amp, 0.25)).play;


Pdef(\t, Pbind(\instrument, \harpsichord_pluck, \dur, Pxrand([0.33,0.33,0.33,0.165,0.165],inf),
	\decaytime, Pwhite(0.0001, 5.5),
	\degree, Pclump( Pseq([3, 3, 4, 2, 4, 2, 4], inf), Pseq([0,1,2,3,4,20,21, 31, 12, 13, 29,4, 5],inf), inf),
	\octave, Prand([2,3,4,5,6,7,8],inf), \scale, b, \amp, 0.25)).play;

//samples
~testSampleNames = "/media/numina/7DB4C58533DB765B/Dropbox/Samples/Field/microsounds/*.aiff".pathMatch;
~testSampleNames = "/media/numina/7DB4C58533DB765B/Samples/Springs/*.wav".pathMatch;
~samples = ~testSampleNames.collect({|i| i.postln; Buffer.read(s, i); });


//samples from objects

~testSampleNames = "/media/numina/7DB4C58533DB765B/Dropbox/Coralie_Vogelaar_Project/HRV_samples/*.wav".pathMatch;
~samples = ~testSampleNames.collect({|i| i.postln; Buffer.read(s, i); });

SynthDef(\HRV_sampler, {|out=0 amp=2, release=0.4 bufnum pos=0 gate=1|
	var env, sig;
	env = EnvGen.ar(Env.perc(0.001,release),doneAction: 2);
	//env = EnvGen.ar(Env.adsr(0.01,0.0,1,2.0), gate, doneAction: 2);
	sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*Rand(0.9,1.1), 1, BufFrames.ir(bufnum) * pos);
	//Out.ar(out, Pan2.ar(sig*amp*env));
	Out.ar(out, sig*amp*env);

}).store;

r = Routine({
	inf.do{ var sample, time;
		sample = ~samples.choose;
		Synth(\HRV_sampler, [\out,0, \bufnum,  sample, \release, rrand(1.0,2.0), \pos, rrand(0.0, 0.5)]);
		time = rrand(0.075, 0.125);
		time.wait;
		Synth(\HRV_sampler, [\out,0, \bufnum,  sample, \release, rrand(1.0,2.0), \pos, rrand(0.0, 0.5)]);
		time = rrand(0.94, 1.05);
		time.wait;
	};
}).play;



s = Routine({
	inf.do{ var sample, time;
		sample = ~samples.choose;
		Synth(\HRV_sampler, [\out,1, \bufnum,  sample, \release, rrand(0.01,0.5), \pos, rrand(0.0, 0.5)]);
		time = rrand(0.025, 0.0625);
		time.wait;
		Synth(\HRV_sampler, [\out,1, \bufnum,  sample, \release, rrand(0.01,0.5), \pos, rrand(0.0, 0.5)]);
		time = rrand(0.46, 0.55);
		time.wait;
	};
}).play;


//Grote Hart schetsen


~testSampleNames = "/media/numina/7DB4C58533DB765B/Dropbox/Coralie_Vogelaar_Project/KeramiekSamples/GroteHart_HardeTik/*.wav".pathMatch
~samples = ~testSampleNames.collect({|i| i.postln; Buffer.read(s, i); });

SynthDef(\HRV_sampler, {|out=0 amp=2, release=0.4 bufnum pos=0 gate=1|
	var env, sig;
	env = EnvGen.ar(Env.perc(0.001,release),doneAction: 2);
	//env = EnvGen.ar(Env.adsr(0.01,0.0,1,2.0), gate, doneAction: 2);
	sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*0.125, 1, BufFrames.ir(bufnum) * pos);
	Out.ar(out, Pan2.ar(sig*amp*env));
	//Out.ar(out, sig*amp*env);

}).store;

r = Routine({
	inf.do{ var sample, time;
		sample = ~samples.choose;
		Synth(\HRV_sampler, [\out,0, \bufnum,  sample, \release, rrand(2.0,4.0), \pos, rrand(0.0, 0.0)]);
		time = rrand(0.075, 0.125);
		time.wait;
		Synth(\HRV_sampler, [\out,0, \bufnum,  sample, \release, rrand(2.0,4.0), \pos, rrand(0.0, 0.0)]);
		time = rrand(0.94, 1.05);
		time.wait;
	};
}).play;
r.stop;

~testSampleNames = "/media/numina/7DB4C58533DB765B/Dropbox/Coralie_Vogelaar_Project/KeramiekSamples/GroteHartAdem/*.wav".pathMatch;
~ademSamples = ~testSampleNames.collect({|i| i.postln; Buffer.read(s, i); });

SynthDef(\HRV_sampler, {|out=0 amp=2, release=0.5 dur=0.5 bufnum pos=0|
	var gate, env, sig;
	//env = EnvGen.ar(Env.perc(0.001,release),doneAction: 2);
	gate = EnvGen.kr(Env.new([1,0], [dur]), 1);
	env = EnvGen.ar(Env.adsr(0.3,0.0,1,2.0), gate, doneAction: 2);
	sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*1, 1, BufFrames.ir(bufnum) * pos);



	//Out.ar(out, Pan2.ar(sig*amp*env*0.5));
	Out.ar(out, sig*amp*env);
}).store;

r = Routine({
	inf.do{ var sample, time;
		sample = ~ademSamples.choose;
		Synth(\HRV_sampler, [\out,1, \amp, rrand(0.05, 2.0), \bufnum,  sample,\dur, rrand(0.08,0.2), \release, rrand(0.05,0.3), \pos, rrand(0.0, 0.5)]);
		time = rrand(0.075, 0.125);
		time.wait;
		Synth(\HRV_sampler, [\out,1, \amp, rrand(0.05, 2.0), \bufnum,  sample,\dur, rrand(0.1,0.3), \release, rrand(0.1,0.3), \pos, rrand(0.0, 0.5)]);
		time = rrand(0.094, 0.2);
		time.wait;
	};
}).play;


r.stop;

Ndef(\whitenoisetest, {

	var sig = WhiteNoise.ar(SinOsc.kr(LFNoise2.kr(0.4).range(0.001,0.1)).range(0.1,0.5));
	//var sig = LFSaw.ar(35,0,0.25);

	sig = PitchShift.ar(sig, 0.2, 0.1);
	sig = MidEQ.ar(sig, SinOsc.kr(0.05).range(100.0,8000),0.2,4);
	//sig = LPF.ar(sig,SinOsc.kr(0.025).range(800, 3000));
	sig = HPF.ar(sig, 40);
	sig = LPF.ar(sig,SinOsc.kr(0.025).range(200, 400));

	//sig = sig!2;
	Out.ar(0, sig);
}).play;



r.stop;







s = Routine({
	inf.do{ var sample, time;
		sample = ~samples.choose;
		Synth(\HRV_sampler, [\out,1, \bufnum,  sample, \release, rrand(0.01,0.5), \pos, rrand(0.0, 0.5)]);
		time = rrand(0.025, 0.0625);
		time.wait;
		Synth(\HRV_sampler, [\out,1, \bufnum,  sample, \release, rrand(0.01,0.5), \pos, rrand(0.0, 0.5)]);
		time = rrand(0.46, 0.55);
		time.wait;
	};
}).play;


Ndef(\sample_rhythm, {
	var sig = Trig.ar(Impulse.ar(0.4, 0, 0.5), 0.5);
	var series = Drand((0..5), inf);
	var sampledem = Demand.kr(sig, 0, series);
	var sample = ~samples[sampledem];
	sig = PlayBuf.ar(1, sample,BufRateScale.kr(sample),sig, BufFrames.ir(sample)*LFNoise0.kr(0.2).range(0.0,0.5) );
}).play;


/* mic input */

Ndef(\mic_input, {
	var sig = SoundIn.ar(0);
	sig = sig!2;
}).play;

Ndef(\pluck_input, {
	var input = SoundIn.ar(0);
	var chain = FFT(LocalBuf(512), input);
	var onsets = Onsets.kr(chain, 0.3, \rcomplex);
	var trig = Trig.ar(onsets, LFNoise0.kr(0.8).range(0.01,0.3));
	var sig = Pluck.ar(input, trig, 440.reciprocal, LFNoise0.kr(3.2).range(220.reciprocal,440.reciprocal), 10, SinOsc.kr(10.0).range(0.5,0.99) );
	sig = sig!2;

}).play;

// onsets & sampling //
SynthDef(\onset_recorder, {|in=0 fftbuf recbuf|
	var input = SoundIn.ar(in);
	var chain = FFT(fftbuf, input);
	var onsets = Onsets.kr(chain, 0.4, \rcomplex);
	RecordBuf.ar(input, recbuf, loop:0, trigger: onsets);
}).store;

~fftBuf = Buffer.alloc(s, 1024, 1);
~recBuf = Buffer.alloc(s, s.sampleRate*1,1);
~onsetRecSynth = Synth(\onset_recorder, [\in, 0, \fftbuf, ~fftBuf, \recbuf, ~recBuf] );

Ndef(\onsets_sampler, {
	var input = SoundIn.ar(0);
	var chain = FFT(LocalBuf(512), input);
	//var onsets = Onsets.kr(chain, 0.3, \rcomplex);
	var onsets = Impulse.ar(LFNoise0.kr(4.2).range(0.9,1.2));
	var trig = Trig.ar(onsets, LFNoise0.kr(0.8).range(0.25,0.25));
	var sig = trig * PlayBuf.ar(1, ~recBuf, BufRateScale.kr(~recBuf), 1, 0.0, 1);
	sig = MidEQ.ar(sig, 1500, 0.1, 6);
	sig = HPF.ar(sig, 50.0);
	sig = LPF.ar(sig, 18000);
	sig = FreeVerb.ar(sig, 0.3, 0.6, 0.6);
	sig = sig ! 2;
}).play;

Ndef(\mic_input, {
	var input = SoundIn.ar(0);
	input = input!2;
}).play;

Ndef(\onsets_impulse, {
	var sig = SoundIn.ar(0);
	var chain = FFT(LocalBuf(512), sig);
	var onsets = Onsets.kr(chain, 0.3, \rcomplex);
	var trig = Trig.ar(onsets, LFNoise0.kr(0.8).range(0.01,0.3));
	sig = trig * LPF.ar(Impulse.ar(SinOsc.kr(1.0).range(300.0,80000.0)), SinOsc.kr(LFNoise1.kr(0.8).range(0.1,32.8)).range(200, 8000.0));
	//sig = CombC.ar(sig, 0.2, SinOsc.kr(LFNoise0.kr(0.4).range(0.1,30.0)).range(0.001,0.01),SinOsc.kr(3).range(5, 15), 0.2, sig * 0.8 );
	//sig = FreeVerb.ar(sig, 0.4, 0.8);
	sig = sig ! 2;
}).play;
