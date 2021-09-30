/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React, {useEffect} from 'react';
import {useState} from 'react';
import {
  Button,
  SafeAreaView,
  Text,
  View,
  NativeModules,
  NativeEventEmitter,
} from 'react-native';

const App = () => {
  const [lastData, setLastData] = useState(null);
  const [isRecording, setIsRecording] = useState(false);

  useEffect(() => {
    // instantiate the event emitter
    const CounterEvents = new NativeEventEmitter(
      NativeModules.MicrophoneRecording,
    );
    // subscribe to event
    CounterEvents.addListener('onRecording', res => {
      const data = res.data.slice(0, 10).map(v => v * 256 * 256);
      console.log('onRecording event', data);
      setLastData(data);
    });
  }, []);

  useEffect(() => {
    NativeModules.MicrophoneRecording.toggleMicTap();
  }, [isRecording]);

  return (
    <SafeAreaView>
      <View>
        <Button
          onPress={() => setIsRecording(!isRecording)}
          title={isRecording ? 'Disable' : 'Enable'}
        />
        <Text>{JSON.stringify(lastData)}</Text>
      </View>
    </SafeAreaView>
  );
};

export default App;
