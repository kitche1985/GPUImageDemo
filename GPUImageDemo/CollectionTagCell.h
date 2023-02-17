//
//  CollectionViewCell.h
//  GPUImageDemo
//
//  Created by sun on 2023/2/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CollectionTagCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;


-(void)reloadCell:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
