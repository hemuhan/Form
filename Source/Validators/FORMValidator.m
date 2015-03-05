#import "FORMValidator.h"
#import "FORMFieldValue.h"
#import "FORMClassFactory.h"

@interface FORMValidator ()

@property (nonatomic, strong) FORMFieldValidation *validation;

@end

@implementation FORMValidator

- (instancetype)initWithValidation:(FORMFieldValidation *)validation
{
    self = [super init];
    if (!self) return nil;

    self.validation = validation;

    return self;
}

- (FORMValidationResultType)validateFieldValue:(id)fieldValue
{
    if (!self.validation) return FORMValidationResultTypePassed;

    if (!fieldValue && !self.validation.isRequired) return YES;

    if ([fieldValue isKindOfClass:[FORMFieldValue class]]) {
        return FORMValidationResultTypePassed;
    }

    if (self.validation.minimumLength > 0) {
        if (!fieldValue) {
            return FORMValidationResultTypeValueMissing;
        } else if ([fieldValue isKindOfClass:[NSString class]]) {
            BOOL fieldValueIsShorter = ([fieldValue length] < self.validation.minimumLength);
            if (fieldValueIsShorter) return FORMValidationResultTypeTooShort;
        }
    }

    if ([fieldValue isKindOfClass:[NSString class]] && self.validation.maximumLength) {
        BOOL fieldValueIsLonger = ([fieldValue length] > self.validation.maximumLength);
        if (fieldValueIsLonger) return FORMValidationResultTypeTooLong;
    }

    if ([fieldValue isKindOfClass:[NSString class]] && self.validation.format) {
        if (![self validateString:fieldValue
                      withFormat:self.validation.format]) {
            return FORMValidationResultTypeInvalidFormat;
        }
    }

    return FORMValidationResultTypePassed;
}

- (BOOL)validateString:(NSString *)fieldValue withFormat:(NSString *)format
{
    if (!fieldValue) return YES;

    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:format options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:fieldValue options:NSMatchingReportProgress range:NSMakeRange(0, fieldValue.length)];
    return (numberOfMatches > 0);
}

+ (Class)classForKey:(NSString *)key andType:(NSString *)type
{
    Class validatorClass = ([FORMClassFactory classFromString:key withSuffix:@"Validator"]);
    if (!validatorClass) {
        validatorClass = ([FORMClassFactory classFromString:type withSuffix:@"Validator"]);
    }
    if (!validatorClass) {
        validatorClass = [FORMValidator class];
    }

    return validatorClass;
}

@end
