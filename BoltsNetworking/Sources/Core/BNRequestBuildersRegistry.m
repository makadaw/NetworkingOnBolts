//
//  BNRequestBuildersRegistry.m
//  BoltsNetworking
//
//  Created by mainuser on 3/10/18.
//

#import "BNRequestBuildersRegistry.h"
#import <pthread.h>

@interface BNRequestBuildersRegistry(){
    pthread_rwlock_t _lock;
}
@property (nonatomic) id<BNRequestBuilder> defaultBuilder;
@property (nonatomic) NSMutableDictionary<NSString*, id<BNRequestBuilder>> *registry;

@end

@implementation BNRequestBuildersRegistry

- (instancetype)initWithDefaultBuilder:(id<BNRequestBuilder>)defaultBuilder {
    if ((self = [super init])) {
        pthread_rwlock_init(&_lock, NULL);
        _defaultBuilder = defaultBuilder;
        _registry = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    pthread_rwlock_destroy(&_lock);
}

- (void)registerRequestBuilder:(NSObject<BNRequestBuilder>*)builder {
    pthread_rwlock_wrlock(&_lock);
    [self.registry setObject:builder forKey:NSStringFromClass([builder class])];
    pthread_rwlock_unlock(&_lock);
}

- (id<BNRequestBuilder>)builderForClass:(Class __unsafe_unretained)class {
    id<BNRequestBuilder> builder;
    pthread_rwlock_rdlock(&_lock);
    builder = self.registry[NSStringFromClass(class)];
    pthread_rwlock_unlock(&_lock);
    if (!builder) builder = self.defaultBuilder;
    return builder;
}

@end
