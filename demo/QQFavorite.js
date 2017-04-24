import React, {Component} from 'react';
import {
  StyleSheet,
  ScrollView,
  Alert,
  Dimensions,
  Button,
  Navigator,
  CameraRoll,
  View
} from 'react-native';
import * as QQ from 'react-native-qqsdk';
import NavigationBar from './navigationBar';
import resolveAssetSource from 'resolveAssetSource';
export default class QQZoneShare extends Component {
  static propTypes = {
    navigator: Navigator.propTypes.navigator,
  };

  render() {
    return (
      <View style={styles.container}>
        <NavigationBar
          navBarTitle="QQ Favorite"
          LeftButtonTitle="Back"
          LeftButtonOnPress={() => {
            this.props.navigator.pop();
          }}
        />
        <ScrollView
          showsHorizontalScrollIndicator={false}
          showsVerticalScrollIndicator={false}
          bounces={false}
        >
          <View style={styles.whiteView}/>
          <Button
            onPress={this.shareText.bind(this)}
            title="文字收藏"
            color="#841584"
          />
          <View style={styles.whiteView}/>
          <Button
            onPress={this.shareImage.bind(this)}
            title="图片收藏"
            color="#841584"
          />
          <View style={styles.whiteView}/>
          <Button
            onPress={this.shareNews.bind(this)}
            title="新闻收藏"
            color="#841584"
          />
          <View style={styles.whiteView}/>
          <Button
            onPress={this.shareAudio.bind(this)}
            title="音乐收藏"
            color="#841584"
          />
        </ScrollView>
      </View>
    );
  }

  shareText() {
    QQ.shareText('这是一段收藏文字', QQ.shareScene.Favorite)
      .then((result) => {
        Alert.alert('QQ收藏结果', ' ' + result);
      })
      .catch((error) => {
        Alert.alert('QQ收藏结果', ' ' + error);
      });
  }

  shareImage() {
    const imgUrl = 'http://ww3.sinaimg.cn/mw690/687520b6jw1faic5ciy9aj20u011had3.jpg';
    QQ.shareImage(imgUrl, '收藏图片的标题', '收藏图片的描述', QQ.shareScene.Favorite)
      .then((result) => {
        Alert.alert('QQ收藏结果', ' ' + result);
      })
      .catch((error) => {
        Alert.alert('QQ收藏结果', ' ' + error);
      });
  }

  shareImageFromLocal() {
    CameraRoll.getPhotos({first: 1, assetType: 'Photos'})
      .then((asset) => console.log(resolveAssetSource(asset.edges[0].node.image).uri), (error) => console.log(error));
  }

  shareNews() {
    const newsUrl = 'https://facebook.github.io/react-native/';
    QQ.shareNews(newsUrl, resolveAssetSource(require('./news.jpg')).uri, '收藏新闻的标题', '收藏新闻的描述', QQ.shareScene.Favorite)
      .then((result) => {
        Alert.alert('QQ收藏结果', ' ' + result);
      })
      .catch((error) => {
        Alert.alert('QQ收藏结果', ' ' + error);
      });
  }

  shareAudio() {
    const audioPreviewUrl = 'https://y.qq.com/portal/song/001OyHbk2MSIi4.html';
    const audioUrl = 'http://stream20.qqmusic.qq.com/30577158.mp3';
    const imgUrl = 'https://y.gtimg.cn/music/photo_new/T001R300x300M000003Nz2So3XXYek.jpg';
    QQ.shareAudio(audioPreviewUrl, audioUrl, imgUrl, '十年', '陈奕迅', QQ.shareScene.Favorite)
      .then((result) => {
        Alert.alert('QQ收藏结果', ' ' + result);
      })
      .catch((error) => {
        Alert.alert('QQ收藏结果', ' ' + error);
      });
  }
}
const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  whiteView: {
    width: Dimensions.get('window').width,
    height: 16,
  }
});
