#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Castar : NSObject

// MARK: - Properties
@property (nonatomic, readonly, getter=isRunning) BOOL running;

// MARK: - Initialization
+ (nullable instancetype)createInstanceWithDevKey:(NSString * _Nullable)devKey;

// MARK: - Device Info Management
- (NSString *)getDevKey;
- (NSString *)getDevSn;

// MARK: - Client Control
- (void)start;
- (void)stop;
- (void)restart;

// MARK: - Retry Logic
- (void)retryWithSeconds:(int64_t)seconds;

@end

NS_ASSUME_NONNULL_END
