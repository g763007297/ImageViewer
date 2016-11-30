//
//  GQBaseObject.m
//  ImageViewer
//
//  Created by 高旗 on 16/11/30.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import "GQImageViewrBaseObject.h"
#import <objc/runtime.h>

/**
 *  Given a scalar or struct value, wraps it in NSValue
 *  Based on EXPObjectify: https://github.com/specta/expecta
 */
static inline id _GQBoxValue(const char *type, ...) {
    va_list v;
    va_start(v, type);
    id obj = nil;
    if (strcmp(type, @encode(id)) == 0) {
        id actual = va_arg(v, id);
        obj = actual;
    } else if (strcmp(type, @encode(CGPoint)) == 0) {
        CGPoint actual = (CGPoint)va_arg(v, CGPoint);
        obj = [NSValue value:&actual withObjCType:type];
    } else if (strcmp(type, @encode(CGSize)) == 0) {
        CGSize actual = (CGSize)va_arg(v, CGSize);
        obj = [NSValue value:&actual withObjCType:type];
    } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
        UIEdgeInsets actual = (UIEdgeInsets)va_arg(v, UIEdgeInsets);
        obj = [NSValue value:&actual withObjCType:type];
    } else if (strcmp(type, @encode(double)) == 0) {
        double actual = (double)va_arg(v, double);
        obj = [NSNumber numberWithDouble:actual];
    } else if (strcmp(type, @encode(float)) == 0) {
        float actual = (float)va_arg(v, double);
        obj = [NSNumber numberWithFloat:actual];
    } else if (strcmp(type, @encode(int)) == 0) {
        int actual = (int)va_arg(v, int);
        obj = [NSNumber numberWithInt:actual];
    } else if (strcmp(type, @encode(long)) == 0) {
        long actual = (long)va_arg(v, long);
        obj = [NSNumber numberWithLong:actual];
    } else if (strcmp(type, @encode(long long)) == 0) {
        long long actual = (long long)va_arg(v, long long);
        obj = [NSNumber numberWithLongLong:actual];
    } else if (strcmp(type, @encode(short)) == 0) {
        short actual = (short)va_arg(v, int);
        obj = [NSNumber numberWithShort:actual];
    } else if (strcmp(type, @encode(char)) == 0) {
        char actual = (char)va_arg(v, int);
        obj = [NSNumber numberWithChar:actual];
    } else if (strcmp(type, @encode(bool)) == 0) {
        bool actual = (bool)va_arg(v, int);
        obj = [NSNumber numberWithBool:actual];
    } else if (strcmp(type, @encode(unsigned char)) == 0) {
        unsigned char actual = (unsigned char)va_arg(v, unsigned int);
        obj = [NSNumber numberWithUnsignedChar:actual];
    } else if (strcmp(type, @encode(unsigned int)) == 0) {
        unsigned int actual = (unsigned int)va_arg(v, unsigned int);
        obj = [NSNumber numberWithUnsignedInt:actual];
    } else if (strcmp(type, @encode(unsigned long)) == 0) {
        unsigned long actual = (unsigned long)va_arg(v, unsigned long);
        obj = [NSNumber numberWithUnsignedLong:actual];
    } else if (strcmp(type, @encode(unsigned long long)) == 0) {
        unsigned long long actual = (unsigned long long)va_arg(v, unsigned long long);
        obj = [NSNumber numberWithUnsignedLongLong:actual];
    } else if (strcmp(type, @encode(unsigned short)) == 0) {
        unsigned short actual = (unsigned short)va_arg(v, unsigned int);
        obj = [NSNumber numberWithUnsignedShort:actual];
    }
    va_end(v);
    return obj;
}

#define GQBoxValue(value) _GQBoxValue(@encode(__typeof__((value))), (value))

typedef void(^GQEnumerateSuper)(Class c , BOOL *stop);

@implementation GQImageViewrBaseObject

+ (NSDictionary *)attributeMapDictionary {
    return [[[[self class] alloc] init] propertiesAttributeMapDictionary];
}

- (id)copy {
    return [self copyWithZone:nil];
}

- (id)copyWithZone:(NSZone *)zone
{
    id object = [[self class] allocWithZone:zone];
    NSDictionary *attrMapDic = [[self class] attributeMapDictionary];
    NSEnumerator *keyEnum = [attrMapDic keyEnumerator];
    id attributeName;
    while ((attributeName = [keyEnum nextObject])) {
        SEL getSel = NSSelectorFromString(attributeName);
        SEL sel = [object getSetterSelWithAttibuteName:attributeName];
        if ([self respondsToSelector:sel] &&
            [self respondsToSelector:getSel]) {
            id valueObj = [self getValue:attributeName];
            if (valueObj) {
                [object setValue:valueObj forKey:attributeName];
            }
        }
    }
    return object;
}

- (id)mutableCopy {
    return [self mutableCopyWithZone:nil];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    id object = [[self class] allocWithZone:zone];
    NSDictionary *attrMapDic = [[self class] attributeMapDictionary];
    NSEnumerator *keyEnum = [attrMapDic keyEnumerator];
    id attributeName;
    while ((attributeName = [keyEnum nextObject])) {
        SEL getSel = NSSelectorFromString(attributeName);
        SEL sel = [object getSetterSelWithAttibuteName:attributeName];
        if ([self respondsToSelector:sel] &&
            [self respondsToSelector:getSel]) {
            id valueObj = [self getValue:attributeName];
            if (valueObj) {
                [object setValue:valueObj forKey:attributeName];
            }
        }
    }
    return object;
}

#pragma mark - private methods
- (SEL)getSetterSelWithAttibuteName:(NSString*)attributeName
{
    NSString *capital = [[attributeName substringToIndex:1] uppercaseString];
    NSString *setterSelStr = [NSString stringWithFormat:@"set%@%@:",capital,[attributeName substringFromIndex:1]];
    return NSSelectorFromString(setterSelStr);
}

/*!
 * get property names of object
 */
- (NSArray*)propertyNames
{
    NSMutableArray *propertyNames = [[NSMutableArray alloc] init];
    [[self class] enumerateCustomClass:^(__unsafe_unretained Class c, BOOL *stop) {
        unsigned int propertyCount = 0;
        objc_property_t *properties = class_copyPropertyList(c, &propertyCount);
        for (unsigned int i = 0; i < propertyCount; ++i) {
            objc_property_t property = properties[i];
            const char * name = property_getName(property);
            [propertyNames addObject:[NSString stringWithUTF8String:name]];
        }
        free(properties);
    }];
    return propertyNames;
}

+ (void)enumerateCustomClass:(GQEnumerateSuper)block {
    if (block == nil) {
        return;
    }
    BOOL stop = NO;
    
    Class c = self;
    
    while (c &&!stop) {
        block(c, &stop);
        
        c = class_getSuperclass(c);
        
        if (![c isSubclassOfClass:[GQImageViewrBaseObject class]]) break;
    }
}

- (id)getValue:(NSString *)property {
    SEL getSel = NSSelectorFromString(property);
    id valueObj = nil;
    if ([self respondsToSelector:getSel]) {
        valueObj =[self valueForKey:property];
    }
    return GQBoxValue(valueObj);
}

// default AttributeMapDictionary
- (NSDictionary*)propertiesAttributeMapDictionary
{
    NSMutableDictionary *attributeMapDictionary = [NSMutableDictionary dictionary];
    NSArray *properties = [self propertyNames];
    for (NSString *property in properties) {
        SEL getSel = NSSelectorFromString(property);
        if ([self respondsToSelector:getSel]) {
            attributeMapDictionary[property] = property;
        }
    }
    return attributeMapDictionary;
}

@end
