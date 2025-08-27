from TTS.api import TTS
from playsound import playsound

tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2", gpu=True)

def loop():
  sentence = "I sexually identify as tyler 1. Ever since I was a kid I dreamed of running it down mid and typing hee hee ex dee to boosted animals"
  while True:
    tts.tts_to_file(
      text=sentence,
      file_path="output.wav",
      speaker_wav=[ "./voice-clips/2b.wav"
        # "./voice-clips/persona5/ann/english/p5r/00312_streaming_dec.wav",
        # "./voice-clips/persona5/ann/english/p5r/00303_streaming_dec.wav",
        #   "./voice-clips/persona5/ann/english/p5r/00285_streaming_dec.wav",
        #   "./voice-clips/persona5/ann/english/p5r/00307_streaming_dec.wav"
      ],
      language="en"
    )
    playsound('output.wav')
    sentence = input('>')

loop()
