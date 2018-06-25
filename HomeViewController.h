//
//  HomeViewController.h
//  CrimeChat
//
//  Created by   on 04/02/17.
//  Copyright © 2017  . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonHeaders.h"
#import "User.h"
#import "NewsFeed.h"
#import "AddressPicker.h"
@interface HomeViewController : UIViewController
{
    User *user;
    TopNavBarView *topView;
    NSMutableArray *arrNewsFeedList;
    NSMutableArray *arrSubscriptionData ;
    NSMutableArray *arrsuburbData ;
    NSInteger totalPages;
    NSInteger currentPageNumber;
    IBOutlet UIImageView *imgViewrightArrowIcon;
    NSString *latitude;
    NSString *longitude;
    NSInteger totalRecords;
    BannerView *bannerview;
    BOOL isSubscribedCity;

    
}
@property (weak, nonatomic) IBOutlet UITableView *tblNewsFeed;
@property (weak, nonatomic) IBOutlet UITableView *tblsuburbList;
@property (weak, nonatomic) IBOutlet UIView *viewAddressPicker;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentLocation;
@property (strong,nonatomic) CLLocationManager *locationManager;
@property (strong,nonatomic) IBOutlet UIView *viewAdBanner;
@property (weak, nonatomic) IBOutlet UILabel *lblNoDataFound;
@property (strong, nonatomic) Subscription *subscription;
@property (nonatomic,strong) VTPickerView *pickerSuburb;


@end
