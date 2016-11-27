//
//  XXZQNetwork.m
//  XXZQNetwork
//
//  Created by XXXBryant on 16/7/22.
//  Copyright © 2016年 张琦. All rights reserved.
//


#ifdef DEBUG
#ifndef XXZQLog
#define XXZQLog(...) NSLog(__VA_ARGS__)
#endif
#else
#ifndef XXZQLog
#define XXZQLog(...) do { } while (0)  /* */
#endif
#endif

#import "XXZQNetwork.h"
#import "AFNetworking.h"
#import "XXZQUploadParam.h"
#import "XXZQNetworkCache.h"

@interface XXZQNetwork()

@property (nonatomic, strong) AFHTTPSessionManager * manager;

@property (nonatomic, strong) NSMutableArray * allSessionTask;

@end

@implementation XXZQNetwork

static id _instance = nil;
static NSMutableArray *_allSessionTask;

/**
 存储着所有的请求task数组
 */
- (NSMutableArray *)allSessionTask
{
    if (!_allSessionTask)
    {
        _allSessionTask = [[NSMutableArray alloc] init];
    }
    return _allSessionTask;
}


+ (instancetype)sharedInstance
{
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
    
}

- (instancetype)init
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init];
        AFNetworkReachabilityManager * manager = [AFNetworkReachabilityManager sharedManager];
        [manager startMonitoring];
        [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusUnknown:
                    XXZQLog(@"未知网络");
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    XXZQLog(@"无法连接网络");
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    XXZQLog(@"wifi网络");
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    XXZQLog(@"当前使用手机网络");
                    break;
                default:
                    break;
            }
        }];
    });
    return _instance;
}

- (AFHTTPSessionManager *)manager
{
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        /**
         *  可以接受的类型
         */
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain",@"image/jpg",@"application/x-javascript",@"keep-alive", nil];
        /**
         *  请求队列允许的最大并发数
         */
        //    manager.operationQueue.maxConcurrentOperationCount = 5;
        
        
        // 设置超时时间
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 20.f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        //设置状态栏的小菊花
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
    });
    return manager;
    
}

//json转字符串
- (NSString *)jsonToString:(id)data
{
    if(!data) { return nil; }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    return jsonString;
}


#pragma mark --GET请求 自动缓存--
- (void)getWithURLString:(NSString *)URLString
              parameters:(NSDictionary *)parameters
           responseCache:(void (^)(id))responseCache
                 success:(void (^)(id))success
                 failure:(void (^)(NSError *))faliure
{
    responseCache ? responseCache([XXZQNetworkCache httpCacheForURLString:URLString parameters:parameters]) : nil;
    
    AFHTTPSessionManager * manager = [self manager];
    
    [manager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self.allSessionTask removeObject:task];
        
        if (success) {
            
            NSString * jsonString = [self jsonToString:responseObject];
            
            success(jsonString);
            
            responseCache ? [XXZQNetworkCache setHttpCache:responseObject URLString:URLString parameters:parameters] : nil;
            
//            XXZQLog(@" 【RECEIVE】 \n%@\n%@\n\n",URLString,jsonString);
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.allSessionTask removeObject:task];
        if (faliure) {
            faliure(error);
            XXZQLog(@"error = %@",error);
        }
    }];
    
    
    
    self.allSessionTask = [NSMutableArray arrayWithArray:self.manager.tasks];
    
    XXZQLog(@"%@",self.allSessionTask);
    
}

#pragma mark --get请求无缓存--
- (void)getWithURLString:(NSString *)URLString
              parameters:(NSDictionary *)parameters
                 success:(void (^)(id))success
                 failure:(void (^)(NSError *))faliure
{
    
    return [self getWithURLString:URLString parameters:parameters responseCache:nil success:success failure:faliure];
}


#pragma mark --POST请求 自动缓存--
- (void)postWithURLString:(NSString *)URLString
               parameters:(NSDictionary *)parameters
            responseCache:(void (^)(id))responseCache
                  success:(void (^)(id))success
                  failure:(void (^)(NSError *))faliure
{
    responseCache ? responseCache([XXZQNetworkCache httpCacheForURLString:URLString parameters:parameters]) : nil;
    
    AFHTTPSessionManager * manager = [self manager];
    
    [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.allSessionTask removeObject:task];
        if (success) {
            responseCache ? [XXZQNetworkCache setHttpCache:responseObject URLString:URLString parameters:parameters] : nil;
            
            NSString * jsonString = [self jsonToString:responseObject];
            
            success(jsonString);
            
//            XXZQLog(@" 【RECEIVE】 \n%@\n%@\n\n",URLString,jsonString);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.allSessionTask removeObject:task];
        if (faliure) {
            faliure(error);
            XXZQLog(@"error = %@",error);
        }
    }];
    
    self.allSessionTask = [NSMutableArray arrayWithArray:self.manager.tasks];
    
    XXZQLog(@"post%@",self.allSessionTask);
}


#pragma mark --POST请求 无缓存--
- (void)postWithURLString:(NSString *)URLString
               parameters:(NSDictionary *)parameters
                  success:(void (^)(id))success
                  failure:(void (^)(NSError *))faliure
{
    return [self postWithURLString:URLString parameters:parameters responseCache:nil success:success failure:faliure];
}


#pragma mark --网络请求  自动缓存--
- (void)requireWithURLString:(NSString *)URLString
                  parameters:(NSDictionary *)parameters
               responseCache:(void (^)(id))responseCache
                        type:(HTTPRequestType)type
                     success:(void (^)(id))success
                     failure:(void (^)(NSError *))faliure
{
    
    responseCache ? responseCache([XXZQNetworkCache httpCacheForURLString:URLString parameters:parameters]) : nil;
    AFHTTPSessionManager * manager = [self manager];
    switch (type) {
        case HTTPRequestTypeGet: {
            [manager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                [self.allSessionTask removeObject:task];
                if (success) {
                    
                    responseCache ? [XXZQNetworkCache setHttpCache:responseObject URLString:URLString parameters:parameters] : nil;
                    NSString * jsonString = [self jsonToString:responseObject];
                    
                    success(jsonString);
                    XXZQLog(@" 【RECEIVE】 \n%@\n%@\n\n",URLString,jsonString);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self.allSessionTask removeObject:task];
                if (faliure) {
                    faliure(error);
                    XXZQLog(@"error = %@",error);
                }
            }];
        }
            break;
        case HTTPRequestTypePost: {
            [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self.allSessionTask removeObject:task];
                if (success) {
                    
                    responseCache ? [XXZQNetworkCache setHttpCache:responseObject URLString:URLString parameters:parameters] : nil;
                    NSString * jsonString = [self jsonToString:responseObject];
                    success(jsonString);
                    XXZQLog(@" 【RECEIVE】 \n%@\n%@\n\n",URLString,jsonString);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self.allSessionTask removeObject:task];
                if (faliure) {
                    faliure(error);
                    XXZQLog(@"error = %@",error);
                }
            }];
            break;
        }
    }
    
    self.allSessionTask = [NSMutableArray arrayWithArray:self.manager.tasks];
}

#pragma mark --网络请求  无缓存--
- (void)requireWithURLString:(NSString *)URLString
                  parameters:(NSDictionary *)parameters
                        type:(HTTPRequestType)type
                     success:(void (^)(id))success
                     failure:(void (^)(NSError *))faliure
{
    return [self requireWithURLString:URLString parameters:parameters responseCache:nil type:type success:success failure:faliure];
}

#pragma mark --上传数据--

- (void)uploadWithURLString:(NSString *)URLString
                 parameters:(NSDictionary *)parameters
                uploadParam:(NSArray<XXZQUploadParam *> *)uploadParams
                    success:(void (^)())success
                    failure:(void (^)(NSError *))failure{
    AFHTTPSessionManager * manager = [self manager];
    
    [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (XXZQUploadParam * uploadParam in uploadParams) {
            [formData appendPartWithFileData:uploadParam.data name:uploadParam.name fileName:uploadParam.filename mimeType:uploadParam.mimeType];
        }
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.allSessionTask removeObject:task];
        if (success) {
            NSString * jsonString = [self jsonToString:responseObject];
            
            success(jsonString);
            XXZQLog(@" 【RECEIVE】 \n%@\n%@\n\n",URLString,jsonString);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.allSessionTask removeObject:task];
        if (failure) {
            failure(error);
            XXZQLog(@"error = %@",error);
        }
    }];
    
    self.allSessionTask = [NSMutableArray arrayWithArray:self.manager.tasks];
}

#pragma mark --下载数据--

-(void)downLoadWithURLString:(NSString *)URLString
                  parameters:(NSDictionary *)parameters
                    progerss:(void (^)())progress
                     success:(void (^)())success
                     failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager * manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    
    NSURLSessionDownloadTask * downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        if (progress) {
            progress();
        }
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return targetPath;
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [self.allSessionTask removeObject:downloadTask];
        if (failure) {
            failure(error);
            XXZQLog(@"error = %@",error);
        }
        
    }];
    
    [downloadTask resume];
     downloadTask ? [self.allSessionTask addObject:downloadTask] : nil ;
    

}

- (void)cancelAllRequest
{
    // 锁操作
    @synchronized(self)
    {
        [self.allSessionTask enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [self.allSessionTask removeAllObjects];
    }
    
}

- (void)cancelRequestForURL:(NSString *)URLString
{
    if (!URLString) { return; }
    @synchronized (self)
    {
        [self.allSessionTask enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([task.currentRequest.URL.absoluteString hasPrefix:URLString]) {
                [task cancel];
                [self.allSessionTask removeObject:task];
                *stop = YES;
            }
        }];
    }

}

@end
