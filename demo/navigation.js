import React, {
  Component,
  PropTypes,
} from 'react';
import {
  Navigator,
  Platform,
  BackAndroid,
} from 'react-native';

let _navigator;
export default class Navigation extends Component {
  static propTypes = {
    initialRoute: PropTypes.object.isRequired,
  };

  componentDidMount() {
    if (Platform.OS === 'android') {
      BackAndroid.addEventListener('hardwareBackPress', () => {
        const routesList = _navigator.getCurrentRoutes();
        if (routesList.length > 1) {
          _navigator.pop();
          return true;
        }
        return false;
      });
    }
  }

  componentWillUnmount() {
    BackAndroid.removeEventListener('hardwareBackPress');
  }

  configureScene(route) {
    if (route.sceneConfig) {
      return route.sceneConfig;
    }
    return Navigator.SceneConfigs.PushFromRight;
  }

  render() {
    return (
      <Navigator
        style={{flex: 1}}
        initialRoute={this.props.initialRoute}
        ref={(navigator) => {
          _navigator = navigator;
        }}
        configureScene={this.configureScene.bind(this)}
        renderScene={(route, navigator) => {
          return <route.component navigator={navigator} {...route} {...route.passProps} />;
        }}
      />
    );
  }
}
export const push = (route) => {
  _navigator && _navigator.push(route);
};
export const resetTo = (route) => {
  _navigator && _navigator.resetTo(route);
};
