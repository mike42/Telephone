//
//  AKTelephoneNumberFormatter.m
//  Modication to format Australian numbers

//  Telephone
//
//  Copyright (c) 2008-2012 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE THE COPYRIGHT HOLDER
//  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "AKTelephoneNumberFormatter.h"


@implementation AKTelephoneNumberFormatter

@synthesize splitsLastFourDigits = splitsLastFourDigits_;

- (NSString *)stringForObjectValue:(id)anObject {
  if (![anObject isKindOfClass:[NSString class]]) {
    return nil;
  }
  
  NSString *theString;
  NSUInteger length = [anObject length];
  
  if ([[NSPredicate predicateWithFormat:@"SELF MATCHES '\\\\d{7,15}'"]
                     evaluateWithObject:anObject]) {
    switch (length) {
      case 7:
        if ([self splitsLastFourDigits]) {  // ### ## ##
          theString = [NSString stringWithFormat:@"%@ %@ %@",
                       [anObject substringWithRange:NSMakeRange(0, 3)],
                       [anObject substringWithRange:NSMakeRange(3, 2)],
                       [anObject substringWithRange:NSMakeRange(5, 2)]];
        } else {                            // ### ####
          theString = [NSString stringWithFormat:@"%@ %@",
                       [anObject substringWithRange:NSMakeRange(0, 3)],
                       [anObject substringWithRange:NSMakeRange(3, 4)]];
        }
        break;
        
      case 8:
        if ([self splitsLastFourDigits]) {  // #### ## ##
          theString = [NSString stringWithFormat:@"%@ %@ %@",
                       [anObject substringWithRange:NSMakeRange(0, 4)],
                       [anObject substringWithRange:NSMakeRange(4, 2)],
                       [anObject substringWithRange:NSMakeRange(6, 2)]];
        } else {                            // #### ####
          theString = [NSString stringWithFormat:@"%@ %@",
                       [anObject substringWithRange:NSMakeRange(0, 4)],
                       [anObject substringWithRange:NSMakeRange(4, 4)]];
        }
        break;
        
      case 10:
        if([[anObject substringWithRange:NSMakeRange(0, 2)] isEqualToString: @"04"]) {
          // Mobile numbers
          if ([self splitsLastFourDigits]) {  // 04## ## ## ##
            theString = [NSString stringWithFormat:@"%@ %@ %@ %@",
                         [anObject substringWithRange:NSMakeRange(0, 4)],
                         [anObject substringWithRange:NSMakeRange(4, 2)],
                         [anObject substringWithRange:NSMakeRange(6, 2)],
                         [anObject substringWithRange:NSMakeRange(8, 2)]];
          } else {                            // 04## ### ###
            theString = [NSString stringWithFormat:@"%@ %@ %@",
                         [anObject substringWithRange:NSMakeRange(0, 4)],
                         [anObject substringWithRange:NSMakeRange(4, 3)],
                         [anObject substringWithRange:NSMakeRange(7, 3)]];
          }
        } else {
          // Landlines etc
          if ([self splitsLastFourDigits]) {  // (##) #### ## ##
            theString = [NSString stringWithFormat:@"(%@) %@ %@ %@",
                         [anObject substringWithRange:NSMakeRange(0, 2)],
                         [anObject substringWithRange:NSMakeRange(2, 4)],
                         [anObject substringWithRange:NSMakeRange(6, 2)],
                         [anObject substringWithRange:NSMakeRange(8, 2)]];
          } else {                            // (##) #### ####
            theString = [NSString stringWithFormat:@"(%@) %@ %@",
                         [anObject substringWithRange:NSMakeRange(0, 2)],
                         [anObject substringWithRange:NSMakeRange(2, 4)],
                         [anObject substringWithRange:NSMakeRange(6, 4)]];
          }
        }
        break;
      default:
        theString = anObject;
        break;
    }
  } else {
    theString = anObject;
  }
  
  return theString;
}

- (BOOL)getObjectValue:(id *)anObject
             forString:(NSString *)string
      errorDescription:(NSString **)error {
  
  BOOL returnValue = NO;
  
  NSMutableCharacterSet *phoneNumberCharacterSet
    = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] copy];
  NSScanner *scanner = [NSScanner scannerWithString:string];
  NSMutableString *telephoneNumber = [[NSMutableString alloc] init];
  
  if ([string hasPrefix:@"+"]) {
    [telephoneNumber appendString:@"+"];
    [scanner setScanLocation:1];
  } else {
    // If the number is not in the international format, allow asterisk and
    // number sign.
    [phoneNumberCharacterSet addCharactersInString:@"*#"];
  }
  
  NSString *aString;
  while (![scanner isAtEnd]) {
    [scanner scanUpToCharactersFromSet:phoneNumberCharacterSet intoString:NULL];
    BOOL scanned = [scanner scanCharactersFromSet:phoneNumberCharacterSet
                                       intoString:&aString];
    if (scanned) {
      [telephoneNumber appendString:aString];
    }
  }
  
  if ([telephoneNumber length] > 0) {
    returnValue = YES;
    if (anObject != NULL) {
      *anObject = [[telephoneNumber copy] autorelease];
    }
  } else if (error != NULL) {
    *error = [NSString stringWithFormat:
              @"Couldn't convert \"%@\" to telephone number",
              string];
  }
  
  [telephoneNumber release];
  [phoneNumberCharacterSet release];
  
  return returnValue;
}

- (NSString *)telephoneNumberFromString:(NSString *)string {
  NSString *telephoneNumber, *error;
  BOOL converted = [self getObjectValue:&telephoneNumber
                              forString:string
                       errorDescription:&error];
  if (converted) {
    return telephoneNumber;
  } else {
    NSLog(@"%@", error);
    return nil;
  }
}

@end
