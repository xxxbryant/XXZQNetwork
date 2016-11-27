//
//  XXZQNetwork.h
//  XXZQNetwork
//
//  Created by XXXBryant on 16/7/22.
//  Copyright © 2016年 张琦. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XXZQUploadParam;
/**
 *  网络请求类型
 */

typedef NS_ENUM(NSUInteger,HTTPRequestType) {
    HTTPRequestTypeGet = 0,
    HTTPRequestTypePost
};

@interface XXZQNetwork : NSObject

+ (instancetype)sharedInstance;

/**
 *  发送get请求
 *
 *  @param URLString        请求的网址字符串
 *  @param parameters       请求的参数
 *  @param responseCache    请求缓存数据的回调
 *  @param success          请求成功的回调
 *  @param failure          请求失败的回调
 */

- (void)getWithURLString: (NSString *)URLString
              parameters: (NSDictionary *)parameters
           responseCache: (void (^)(id responseCache))responseCache
                 success: (void (^)(id responseObject))success
                 failure: (void (^)(NSError * error))faliure;

//get请求无缓存
- (void)getWithURLString: (NSString *)URLString
              parameters: (NSDictionary *)parameters
                 success: (void (^)(id responseObject))success
                 failure: (void (^)(NSError * error))faliure;

/**
 *  发送post请求
 *
 *  @param URLString        请求的网址字符串
 *  @param parameters       请求的参数
 *  @param responseCache    请求缓存数据的回调
 *  @param success          请求成功的回调
 *  @param failure          请求失败的回调
 */

- (void)postWithURLString: (NSString *)URLString
               parameters: (NSDictionary *)parameters
            responseCache: (void (^)(id responseCache))responseCache
                  success: (void (^)(id responseObject))success
                  failure: (void (^)(NSError * error))faliure;

//post请求无缓存
- (void)postWithURLString: (NSString *)URLString
               parameters: (NSDictionary *)parameters
                  success: (void (^)(id responseObject))success
                  failure: (void (^)(NSError * error))faliure;

/**
 *  发送网络请求
 *
 *  @param URLString        请求的网址字符串
 *  @param parameters       请求的参数
 *  @param responseCache    请求缓存数据的回调
 *  @param type             请求的类型
 *  @param resultBlock      请求的结果
 */

- (void)requireWithURLString: (NSString *)URLString
                  parameters: (NSDictionary *)parameters
               responseCache: (void (^)(id responseCache))responseCache
                        type: (HTTPRequestType)type
                     success: (void (^)(id responseObject))success
                     failure: (void (^)(NSError * error))faliure;


//无缓存的网络请求
- (void)requireWithURLString: (NSString *)URLString
                  parameters: (NSDictionary *)parameters
                        type: (HTTPRequestType)type
                     success: (void (^)(id responseObject))success
                     failure: (void (^)(NSError * error))faliure;

/**
 *  上传图片
 *
 *  @param URLString        上传图片的网址字符串
 *  @param parameters       上传图片的参数
 *  @param uploadParam      上传图片的信息
 *  @param success          上传成功的回调
 *  @param failure          上传失败的回调
 */
- (void)uploadWithURLString:(NSString *)URLString
                 parameters:(NSDictionary *)parameters
                uploadParam:(NSArray <XXZQUploadParam *> *)uploadParams
                    success:(void (^)())success
                    failure:(void (^)(NSError *error))failure;

/**
 *  下载数据
 *
 *  @param URLString   下载数据的网址
 *  @param parameters  下载数据的参数
 *  @param success     下载成功的回调
 *  @param failure     下载失败的回调
 */
- (void)downLoadWithURLString:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                     progerss:(void (^)())progress
                      success:(void (^)())success
                      failure:(void (^)(NSError *error))failure;

/**
 *  取消所有请求
 */
- (void)cancelAllRequest;

/**
 *  取消某个请求
 */
- (void)cancelRequestForURL: (NSString *)URLString;



@end
