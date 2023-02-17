//
//  CollectionViewCell.m
//  GPUImageDemo
//
//  Created by sun on 2023/2/14.
//

#import "CollectionTagCell.h"

@implementation CollectionTagCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)reloadCell:(NSString *)name {
    self.nameLabel.text = name;
}
@end
