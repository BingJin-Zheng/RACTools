//
//  Sequence_VC.m
//  RACTools
//
//  Created by 郑冰津 on 2016/11/19.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Sequence_VC.h"

@interface Sequence_VC ()

@end

@implementation Sequence_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"RAC数据的操作";
    arrayVClass = @[@"sequence的数组操作",@"sequence的字典操作",@"json转模型"].mutableCopy;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"RACSequence_NSArray",@"RACSequence_NSDictionary",@"RACSequence_Model"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}

///RAC中数组的操作
- (void)RACSequence_NSArray{
    // 1.遍历数组
    NSArray *numbers = @[@1,@2,@3,@4];
    // 这里其实是三步
    // 第一步: 把数组转换成集合RACSequence numbers.rac_sequence
    // 第二步: 把集合RACSequence转换RACSignal信号类,numbers.rac_sequence.signal
    // 第三步: 订阅信号，激活信号，会自动把集合中的所有值，遍历出来。
    [numbers.rac_sequence.signal subscribeNext:^(NSNumber * x) {
        NSLog(@"遍历数组:%@",x);
    }];
    
    NSArray *dictArr = @[@{@"1":@"A",@"2":@"B"},@{@"3":@"C",@"5":@"D"},@{@"姓名":@"郑"}];
    // map:映射的意思，目的：把原始值value映射成一个新值
    // array: 把集合转换成数组
    // 底层实现：当信号被订阅，会遍历集合中的原始值，映射成新值，并且保存到新的数组里。
    NSArray *flags = [[dictArr.rac_sequence map:^id(id value) {
        NSLog(@"value:%@",value);
        return [NSString stringWithFormat:@"组装这个%@",value];
    }] array];
    NSLog(@"%@",flags[2]);
}
///RAC中字典的操作
- (void)RACSequence_NSDictionary{
    // 2.遍历字典,遍历出来的键值对会包装成RACTuple(元组对象)
    NSDictionary *dict = @{@"name":@"xmg",@"age":@18};
    [dict.rac_sequence.signal subscribeNext:^(RACTuple * x) {
        // 解包元组，会把元组的值，按顺序给参数里面的变量赋值
        RACTupleUnpack(NSString *key,NSString *value) = x;
        // 相当于以下写法
        //        NSString *key = x[0];
        //        NSString *value = x[1];
        NSLog(@"key:%@ value:%@",key,value);
    }];
}

- (void)RACSequence_Model{
    NSArray *array = @[@{@"name":@"郑冰津",@"age":@"18"},@{@"name":@"郑冰津1",@"age":@"17"},@{@"name":@"郑冰津2",@"age":@"16"}];
    NSMutableArray *dataSource = [NSMutableArray array];
    [array.rac_sequence.signal subscribeNext:^(NSDictionary *x) {
        Model *model = [Model new];
        [model setValuesForKeysWithDictionary:x];
        [dataSource addObject:model];
        NSLog(@"%@",model.name);
    }];
    
    //高级用法
    NSArray *arr = [[array.rac_sequence map:^id(NSDictionary* value) {
        //        value是集合中的元素
        //        id返回对象就是映射的值
        Model *model = [Model new];
        [model setValuesForKeysWithDictionary:value];
        return model;
    }]array];
    
    NSLog(@"%@",arr);
}

@end


@implementation Model

@end



