import React, { Component } from 'react';
import {
  AppRegistry,
  View
} from 'react-native';
import Navigation from './navigation';
import MainPage from './mainPage'
export default class Test extends Component {
  render() {
   return  (
    <Navigation initialRoute={{component: MainPage}} />
    )
  }
}
AppRegistry.registerComponent('Test', () => Test);
