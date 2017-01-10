import React, {
  Component,
  PropTypes,
} from 'react';
import {
  StyleSheet,
  View,
  Text,
  Dimensions,
  Platform,
  TouchableWithoutFeedback,
} from 'react-native';
export default class NavigationBar extends Component {
  static propTypes = {
    navBarTitle: PropTypes.string,
    LeftButtonTitle: PropTypes.string,
    LeftButtonOnPress: TouchableWithoutFeedback.propTypes.onPress,
  };
  render() {
    return (
        <View style={styles.navbar}>
            <View style={styles.navBarButtonContainer}>
            <Text style={styles.navBarButton} onPress = {this.props.LeftButtonOnPress} >{this.props.LeftButtonTitle}</Text>
            </View>            
            <View style={styles.navBarTitleContainer}>
              <Text style={styles.navbarTitle}>{this.props.navBarTitle}</Text>
            </View>
            <View style={styles.navBarButtonContainer}>
            <Text style={styles.navBarButton}></Text>
            </View>
        </View>
    );
  }
}
const styles = StyleSheet.create({
  navbar: {
    justifyContent: 'space-between',
    flexDirection: 'row',
    alignItems: 'stretch',
    height:44,
    marginTop:Platform.OS === 'ios'? 20:0,
    width:Dimensions.get('window').width,
    backgroundColor:'#ffffff',
    borderBottomWidth:1,
    borderBottomColor: '#C8C8C8'
  },
  navBarTitleContainer:{
    justifyContent: 'center',
    alignItems: 'center',
  },
  navbarTitle:{
    fontSize: 17,
    letterSpacing: 0.5,
    color: '#333',
    fontWeight: '500',
  },
  navBarButtonContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
   navBarButton:{
    fontSize: 17,
    letterSpacing: 0.5,
    color: '#333',
    fontWeight: '500',
    marginLeft:16,
    marginRight:16,
  },
});
