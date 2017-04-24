import React, { Component } from 'react';
import {
  StyleSheet,
  ScrollView,
  Alert,
  Dimensions,
  Button,
  Navigator,
  View
} from 'react-native';
import * as QQ from 'react-native-qqsdk';
import NavigationBar from './navigationBar';
import QQShare from './QQShare';
import QQZone from './QQZoneShare';
import Favorite from './QQFavorite';
export default class MainPage extends Component {
  static propTypes = {
    navigator: Navigator.propTypes.navigator,
  };
  render() {
    return (
      <View style={styles.container}>
        <NavigationBar
        navBarTitle="QQ Demo"
        />
        <ScrollView
          showsHorizontalScrollIndicator={false}
          showsVerticalScrollIndicator={false}
          bounces={false}
        >
        <View style={styles.whiteView}/>
          <Button
            onPress={this.checkClient.bind(this)}
            title="检查客户端是否安装"
            color="#841584"
          />
          <View style={styles.whiteView}/>
          <Button
            onPress={this.Login.bind(this)}
            title="QQ 登录"
            color="#841584"
          />
          <View style={styles.whiteView}/>
          <Button
            onPress={this.Logout.bind(this)}
            title="QQ登出"
            color="#841584"
          />
          <View style={styles.whiteView}/>
          <Button
            onPress={this.QQShare.bind(this)}
            title="QQ分享"
            color="#841584"
          />
          <View style={styles.whiteView}/>
          <Button
            onPress={this.QQZoneShare.bind(this)}
            title="QQZone分享"
            color="#841584"
          />
          <View style={styles.whiteView}/>
          <Button
            onPress={this.QQFavorites.bind(this)}
            title="QQ收藏"
            color="#841584"
          />
        </ScrollView>
      </View>
    );
  }
  checkClient() {
    QQ.isQQClientInstalled()
      .then(()=>{
      Alert.alert('检查客户端是否安装结果','Intsalled');
    }).catch((error)=>{
      Alert.alert('检查客户端是否安装结果',''+error);
    });
  }
  Login() {
    QQ.ssoLogin()
      .then((result)=>{
      Alert.alert('QQ登录结果','userid is '+result.userid+'\n token is '+result.access_token+'\n expires_time is '+ new Date(parseInt(result.expires_time)));
    }).catch((error)=>{
      Alert.alert('QQ登录结果',''+error);
    });
  }
  Logout() {
    QQ.logout()
    .then((result)=>{
      Alert.alert('QQ登出',''+result);
    }).catch((error)=>{
      Alert.alert('QQ登出',''+error);
    });
  }
  QQShare() {
    this.props.navigator.push({component: QQShare});
  }
  QQZoneShare(){
    this.props.navigator.push({component: QQZone});
  }
  QQFavorites() {
     this.props.navigator.push({component: Favorite});
  }
}
const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  whiteView: {
    width:Dimensions.get('window').width,
    height:16,
  },
});
