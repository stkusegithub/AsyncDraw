//
//  iConstant.h
//  iOS_BananaCP
//
//  Created by Stk on 2019/6/27.
//  Copyright © 2019 STK. All rights reserved.
//

#ifndef iConstant_h
#define iConstant_h

#define kCommonEdge 15.f
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width// 屏幕宽度
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height// 屏幕高度
#define IsIPhoneX ((ScreenWidth == 375 && ScreenHeight == 812) || (ScreenWidth == 414 && ScreenHeight == 896))
#define kStatusBarHeight (IsIPhoneX? 44.f:20.f)// 状态栏
#define kNaviBarHeight (IsIPhoneX? 88.f:64.f)// 导航栏
#define kTabBarHeight (IsIPhoneX? 83.f:49.f)// tabbar高度
#define kBottomAppendHeight (IsIPhoneX ? 34.f : 0.f)
#define kSpaceToScreenTop(v) (IsIPhoneX? (24.f+v):v)
/**宽度等比适配*/
#define kScaleWidth(__VA_ARGS__)  ([UIScreen mainScreen].bounds.size.width/375)*(__VA_ARGS__)
/**高度等比适配*/
#define kScaleHeight(__VA_ARGS__)  ([UIScreen mainScreen].bounds.size.height/667)*(__VA_ARGS__)

#define kCommonPageSize 10// 分页数量
#define kPictureTest @"https://5b0988e595225.cdn.sohucs.com/images/20190316/a2b4fe8ce83a453a91354d6e88751f2a.jpeg"

#endif /* iConstant_h */
