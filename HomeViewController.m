
//
//  HomeViewController.m
//  CrimeChat
//
//  Created by   on 04/02/17.
//  Copyright © 2017  . All rights reserved.
//

#import "HomeViewController.h"
#import "AddressPicker.h"
@interface HomeViewController ()<CLLocationManagerDelegate>{
    
    CLGeocoder *geocoder;
    CLLocation *selectedlocation;
    NSString *category_Id;
    NSString *cityId;
}

@end

@implementation HomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSStandardUserDefaults removeObjectForKey:@"selectedCatogories"];
    [NSStandardUserDefaults synchronize];
    
    _viewAddressPicker.hidden = YES;
    
    [self updateDeviceToken];
    _lblNoDataFound.hidden = YES;
    currentPageNumber = 0;
    user = [User loggedInUser];
    
    if(!_subscription) {
        [imgViewrightArrowIcon setHidden:FALSE];
        [self initLocation];
    }
    else {
        //[imgViewrightArrowIcon setHidden:TRUE];
        
        _lblAddress.text = [NSString stringWithFormat:@"%@, %@",_subscription.suburbName,_subscription.countryName];

        [_viewAddressPicker whenTapped:^{
            if (arrsuburbData.count>0) {
                [self showSuburbPicker];
            }
        }];
        
        
        [self getNewsFeedsWithSelectedCityWithCategoryId:nil];
    }
    [self getSubscriptionList];
    
    arrNewsFeedList=[[NSMutableArray alloc]init];
    arrSubscriptionData = [[NSMutableArray alloc]init];
    arrsuburbData = [[NSMutableArray alloc]init];
    
    [self addNavigatioinBarview];
    [_viewAddressPicker addShadow:5 Radius:0 BorderColor:[UIColor whiteColor] ShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    bannerview = [[BannerView alloc]init];
    [bannerview showBannerAdInView:_viewAdBanner completed:^(BOOL hide) {
        _viewAdBanner.hidden = hide;
        CGFloat tblFullHeight = SCREEN_HEIGHT()-_tblNewsFeed.y;
        _tblNewsFeed.height = hide?tblFullHeight:tblFullHeight-_viewAdBanner.height;
    }];
    
}

-(void)initLocation
{
    
    [[AddressPicker sharedInstance] getCurrentLocationInfo:^(CLLocationCoordinate2D coordinate, NSString *formattedAddress, GMSAddress *address) {
        if([formattedAddress isValid]) {
            
            latitude = [NSString stringWithFormat:@"%.8f", coordinate.latitude];
            longitude = [NSString stringWithFormat:@"%.8f", coordinate.longitude];
            
            NSString *strText = @"(Current Location)";
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, %@ %@",address.locality,address.country,strText]];
            
            [attributedString addAttribute:NSForegroundColorAttributeName value:lighterGrayColor() range:[attributedString.string rangeOfString:strText]];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kRegularFontName size:11] range:[attributedString.string rangeOfString:strText]];
            
            [_lblAddress setAttributedText:attributedString];
            
            
           //  _lblAddress.text = [NSString stringWithFormat:@"%@, %@ %@",address.locality,address.country,@"(Current Location)"];
            selectedlocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            currentPageNumber = 0;
            if(_subscription) {
                [self getNewsFeedsWithSelectedCityWithCategoryId:nil];
            }
            else {
                [self getNewsFeeds:nil location:selectedlocation];
            }
        }
        else {
            [_lblNoDataFound setHidden:[arrNewsFeedList count]];
        }
    }];
    [_viewAddressPicker whenTapped:^{
        
        if (arrsuburbData.count>0) {
            
            [self showSuburbPicker];
        }
        
    }];
}

#pragma mark - Top Navigation Bar
-(void)addNavigatioinBarview
{
    
    [self.view addSubview:({
        topView = [TopNavBarView getTopNavBarView];
        [topView.lblTitle setHidden:YES];
        [topView.userDetails setHidden:YES];
        [topView.lblUserLetterImage setHidden:NO];
        [topView.lblnavTitle setText:@"Newsfeed"];
        [topView setLeftBarButtons:[self leftButtons]];
        [topView setRightBarButtons:[self rightButtons]];
        topView.view;
    })];
    
}

- (NSMutableArray *) leftButtons {
    NSMutableArray *arrLeftButtons = [[NSMutableArray alloc] init];
    [arrLeftButtons addBarButtonWithTintColor:[UIColor whiteColor] icon:[UIImage imageNamed:@"menu_icon"] target:self selector:@selector(showSideMenu) forControlEvents:UIControlEventTouchUpInside];
    return arrLeftButtons;
}

- (NSMutableArray *) rightButtons {
    
    NSMutableArray *arrRightButtons = [[NSMutableArray alloc] init];
   // if (_subscription) {
        
        
//        [arrRightButtons addBarButtonWithTintColor:[UIColor whiteColor] icon:[UIImage imageNamed:@"filter_icon"] target:self selector:@selector(showCategories) forControlEvents:UIControlEventTouchUpInside];
    //}else{
        
        [arrRightButtons addBarButtonWithTintColor:[UIColor clearColor] icon:[UIImage imageNamed:@"sync_icon"] target:self selector:@selector(btnRefreshClick) forControlEvents:UIControlEventTouchUpInside];
        [arrRightButtons addBarButtonWithTintColor:[UIColor whiteColor] icon:[UIImage imageNamed:@"filter_icon"] target:self selector:@selector(showCategories) forControlEvents:UIControlEventTouchUpInside];
        [arrRightButtons addBarButtonWithTintColor:[UIColor whiteColor] icon:[UIImage imageNamed:@"white_locationpin"] target:self selector:@selector(showNearby) forControlEvents:UIControlEventTouchUpInside];
        
    //}
    
    
    return arrRightButtons;
}

#pragma mark BtnRefresh Click
-(void)btnRefreshClick
{
    isSubscribedCity = FALSE;
     currentPageNumber = 0;
    [self getNewsFeeds:nil location:selectedlocation];
    [[AddressPicker sharedInstance] getCurrentLocationInfo:^(CLLocationCoordinate2D coordinate, NSString *formattedAddress, GMSAddress *address) {
        
        if([formattedAddress isValid]) {
            latitude = [NSString stringWithFormat:@"%.8f", coordinate.latitude];
            longitude = [NSString stringWithFormat:@"%.8f", coordinate.longitude];
            //_lblAddress.text = [NSString stringWithFormat:@"%@, %@",address.locality,address.country];
            NSString *strText = @"(Current Location)";
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, %@ %@",address.locality,address.country,strText]];
            [attributedString addAttribute:NSForegroundColorAttributeName value:lighterGrayColor() range:[attributedString.string rangeOfString:strText]];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kRegularFontName size:11] range:[attributedString.string rangeOfString:strText]];
            [_lblAddress setAttributedText:attributedString];
            //            _lblAddress.text = [NSString stringWithFormat:@"%@, %@ %@",address.locality,address.country,strText];
            selectedlocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        }
        
    }];
}

#pragma mark ShowSideMenu

-(void)showSideMenu
{
    SideMenuViewController *sidemenuVC = [kStoryboard instantiateViewControllerWithIdentifier:@"SideMenuViewController"];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionMoveIn;
    transition.subtype= kCATransitionFromLeft;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:sidemenuVC animated:NO];
}


#pragma mark Show Nearby
-(void)showNearby
{
    NearByViewController *nearbyVC = [kStoryboard instantiateViewControllerWithIdentifier:@"NearByViewController"];
    nearbyVC.isFromHome = TRUE;
    [self.navigationController pushViewController:nearbyVC animated:YES];
}

#pragma mark showCategories

-(void)showCategories
{
    CategorieViewController *catVC = [kStoryboard instantiateViewControllerWithIdentifier:@"CategorieViewController"];
    [self presentPopupViewController:catVC animationType:MJPopupViewAnimationSlideBottomTop backgroundTouch:FALSE dismissed:^{
        
        if(!catVC.isDataupdated) {
            return;
        }
        if (catVC.catId) {
            currentPageNumber = 0;
            category_Id = catVC.catId;
            
            if(_subscription) {
                [self getNewsFeedsWithSelectedCityWithCategoryId:category_Id];
            }
            else if (isSubscribedCity)
            {
                [self getNewsFeedsWithSelectedCityid:category_Id];
            }
            
            else {
                [self getNewsFeeds:category_Id location:selectedlocation];
            }
            
        }
        else{
            currentPageNumber = 0;
            if(_subscription) {
                [self getNewsFeedsWithSelectedCityWithCategoryId:nil];
            }
            else if (isSubscribedCity)
            {
                [self getNewsFeedsWithSelectedCityid:category_Id];
            }
            
            else {
                [self getNewsFeeds:nil location:selectedlocation];
            }
        }
        
    }];
}

#pragma mark Tableview methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrNewsFeedList count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsFeed *objfeed=[arrNewsFeedList objectAtIndex:indexPath.row];
    CGFloat height = 40;
    UIFont *semiboldFont = [UIFont fontWithName:fontNameFromType(@"semibold") size:14.0];
    CGFloat heightPostTitle = [objfeed.postTitle sizeForMaxWidth:tableView.width - 130 withFont:semiboldFont].height;
    
    if(heightPostTitle > semiboldFont.lineHeight * 2 + 5) {
        heightPostTitle = semiboldFont.lineHeight * 2 + 5;
    }
    height = height + heightPostTitle;
    
    CGFloat heightPostDescription = [objfeed.postDescription sizeForMaxWidth:tableView.width - 60 withFont:[UIFont fontWithName:fontNameFromType(@"semibold") size:15.0]].height + 20;
    height = height + heightPostDescription;
    
    if([objfeed.postImage isValid]) {
        height = height + 115; // imageHeight
    }
    height = height + 40 + 10; //LikeView;
    if (objfeed.commentDetail.count == 0) {
        return height;
    }else {
        if (objfeed.commentDetail.count == 1) {
            CGFloat viewHeight = [self getHeightFromCommentDetail:[objfeed.commentDetail objectAtIndex:0]];
            height = height + viewHeight + 10;
            return height;
        }else if (objfeed.commentDetail.count >= 2){
            CGFloat viewHeight = [self getHeightFromCommentDetail:[objfeed.commentDetail objectAtIndex:0]];
            viewHeight = viewHeight + [self getHeightFromCommentDetail:[objfeed.commentDetail objectAtIndex:1]];
            height = height + viewHeight + 42;
            return height;
        }
    }
    return height;
}

- (CGFloat)getHeightFromCommentDetail:(CommentDetail *)commentDetail {
    UIFont *font = [UIFont fontWithName:fontNameFromType(@"regular") size:11.0];
    CGFloat viewHeight = [commentDetail.comment sizeForMaxWidth:_tblNewsFeed.width - 120 withFont:font].height + 45;
    
    if(viewHeight > (font.lineHeight * 2) + 45) {
        viewHeight = (font.lineHeight * 2) + 45;
    }
    return viewHeight;
}

-(NewsFeedCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NewsFeedCell";
    NewsFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NewsFeed *objfeed = [arrNewsFeedList objectAtIndex:indexPath.row];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[objfeed.createdDate doubleValue]];
    cell.lblNewsDate.text = [date customTimeAgoString];
    [cell.imgAlert setHidden:![objfeed.postEmergencyLevel boolValue]];
    if (objfeed.likeStatus ) {
        [cell.btnLike setImage:[UIImage imageNamed:@"fill_like_icon.png"] forState:UIControlStateNormal];
        [cell.lblCountLike setTextColor:defaultSkyBlueColor()];
    }else{
        [cell.btnLike setImage:[UIImage imageNamed:@"like_icon.png"] forState:UIControlStateNormal];
        [cell.lblCountLike setTextColor:PlaceholderColor()];
    }
    [cell.btnLike whenTapped:^{
        [self likeWebServiceCall:objfeed.postId SelectItemAtIndexPath:indexPath];
    }];
    [cell.imgReportFlag setImage:[UIImage imageNamed:objfeed.report_abuse_post_status ? @"report_red_flag" :  @"report_flag"]];
    
    [cell.imgReportFlag whenTapped:^{
        NSLog(@"UserID :%@",user.userID);
        NSLog(@"POSTID :%@",objfeed.postId);
        if (objfeed.report_abuse_post_status) {
            [ToastView show:@"Report already sent"];
        }else{
            [UIAlertController showAlertInViewController:self withTitle:@"" message:@"Report this post as abusive?" cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Yes"] tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                if (buttonIndex == 2) {
                    if (!objfeed.report_abuse_post_status){
                        [cell.imgReportFlag setImage:[UIImage imageNamed:@"report_red_flag"]];
                        [self reportAbuseWebServiceCall:objfeed.postId SelectItemAtIndexPath:indexPath];
                    }
                    else{
                        
                    }
                }
            }];
        }
    }];
    [cell.viewShareCounts whenTapped:^{
        
        
        NSString *download = [NSString stringWithFormat:@"%@%@",@"Don’t miss posts like these in future. Keep you and your loved ones safe and informed - download CrimeChat here: ",DOWNLOAD_URL];
        
        NSString *authorPost = [NSString stringWithFormat:@"%@\n\n%@%@%@%@\n%@\n%@\n\n%@",@"Have you heard?",objfeed.fullName,@" posted on the ",objfeed.suburbName,@" Newsfeed ",objfeed.postTitle,objfeed.postDescription,download];
        
        //NSString *shareText = [NSString stringWithFormat:@"%@%@\n\n%@%@",@"",objfeed.postDescription,@"Download CrimeChat Application: ",DOWNLOAD_URL];
        
        [self shareText:authorPost andUrl:nil];
    }];
    [cell.viewCommentCounts whenTapped:^{
        [self viewAllcomments:objfeed];
    }];
    
    [cell.imgPostImage setImageWithURL:[NSURL URLWithString:objfeed.postImage] placeholderImage:[UIImage imageNamed:@"newsfeed_placeholder"]];
    [cell.imgPostImage whenTapped:^{
        [ShowImageViewController presentFromViewControllerFromViewController:self images:[@[objfeed.postImage] mutableCopy] selectedIndex:0];
    }];
    
    //if user post as anonymous
    if ([objfeed.postUserIdentity intValue]== 2) {
        
        cell.imgProfilePhoto.image = [UIImage imageNamed:@"anonymous_round_img"];
        
    }
    else{
        
        [cell.imgProfilePhoto setImageWithURL:objfeed.profilePhoto placeHolderImage:PlaceholderUserImage() usingActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        
    }
    
    
    [cell.imgProfilePhoto.layer setCornerRadius:cell.imgProfilePhoto.width/2];
    
    cell.lblFullName.text = objfeed.fullName;
    cell.lblPostTitle.text = objfeed.postTitle;
    cell.lblPostTitle.height = [objfeed.postTitle sizeForMaxWidth:tableView.width - 130 withFont:cell.lblPostTitle.font].height;
    //comment on 22 june
    //[cell.lblPostDescription moveBottomOf:cell.lblPostTitle margin:10];
    [cell.txtViewPostDescription moveBottomOf:cell.lblPostTitle margin:10];
    
    NSString *trimmedDesc = [objfeed.postDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *strPostDescription = trimmedDesc;
    //comment on 22 june
    //cell.lblPostDescription.text = strPostDescription;
    //cell.lblPostDescription.height = [strPostDescription sizeForMaxWidth:tableView.width - 60 withFont:cell.lblPostDescription.font].height;
    
    cell.txtViewPostDescription.text = strPostDescription;
    cell.txtViewPostDescription.height = [strPostDescription sizeForMaxWidth:tableView.width - 60 withFont:cell.txtViewPostDescription.font].height;
    
    //comment on 22 june
    //cell.viewData.height = cell.lblPostDescription.bottom + 10;
    cell.viewData.height = cell.txtViewPostDescription.bottom + 10;
    
    if(![objfeed.postImage isValid] && objfeed.commentDetail.count == 0) {
        //Post image and Comments not available
        cell.viewSeprator.hidden = FALSE;
        cell.viewImg.hidden = TRUE;
        cell.viewComment.hidden = TRUE;
        [cell.viewAllComment setHidden:TRUE];
        [cell.viewSeprator moveBottomOf:cell.viewData margin:0];
        [cell.viewLike moveBottomOf:cell.viewData margin:0];
        cell.viewMainDataContainer.height = cell.viewLike.bottom;
    }else {
        if([objfeed.postImage isValid] && objfeed.commentDetail.count == 0) {
            //Post image available and Comments not available
            cell.viewSeprator.hidden = TRUE;
            cell.viewImg.hidden = FALSE;
            cell.viewComment.hidden = TRUE;
            [cell.viewAllComment setHidden:TRUE];
            [cell.viewImg moveBottomOf:cell.viewData margin:0];
            [cell.viewLike moveBottomOf:cell.viewImg margin:0];
            cell.viewMainDataContainer.height = cell.viewLike.bottom;
        }
        else if(objfeed.commentDetail.count > 0) {
            // Post image not available / commmets available
            cell.viewImg.hidden = ![objfeed.postImage isValid];
            [cell.viewComment setHidden:FALSE];
            
            cell.viewComment.layer.cornerRadius = 4.0f;
            cell.viewComment.layer.borderColor = [UIColor lightGrayColor].CGColor;
            cell.viewComment.layer.borderWidth = 0.5f;
            if (objfeed.commentDetail.count >= 2) {
                [cell.viewAllComment setHidden:FALSE];
                CommentDetail *commentDetail1 = [objfeed.commentDetail objectAtIndex:0];
                cell.lblCommentFullName1.text = commentDetail1.fullName;
                cell.lblcomment1.text = commentDetail1.comment;
                cell.lblcomment1.height = [commentDetail1.comment sizeForMaxWidth:_tblNewsFeed.width - 120 withFont:cell.lblcomment1.font].height;
                CGFloat maxComment1Height = ceil(cell.lblcomment1.font.lineHeight) * 2;
                if (cell.lblcomment1.height > maxComment1Height ) {
                    cell.lblcomment1.height = maxComment1Height;
                }
                // [cell.lblcomment1 sizeToFit];
                [cell.viewUser1 setHeight:cell.lblcomment1.bottom + 10];
                CommentDetail *commentDetail2 = [objfeed.commentDetail objectAtIndex:1];
                cell.lblCommentFullName2.text =commentDetail2.fullName;
                cell.lblcomment2.text =commentDetail2.comment;
                cell.lblcomment2.height = [commentDetail2.comment sizeForMaxWidth:_tblNewsFeed.width - 120 withFont:cell.lblcomment2.font].height;
                CGFloat maxComment2Height = ceil(cell.lblcomment2.font.lineHeight) * 2;
                if (cell.lblcomment2.height > maxComment2Height ) {
                    cell.lblcomment2.height = maxComment2Height;
                }
                [cell.viewUser2 setHeight:cell.lblcomment2.bottom + 10];
                [cell.viewUser2 moveBottomOf:cell.viewUser1 margin:0];
                [cell.viewComment setHeight:cell.viewUser1.height + cell.viewUser2.height];
                cell.viewUser2.hidden = NO;
                
                NSDate *dateComment1 = [NSDate dateWithTimeIntervalSince1970:[commentDetail1.createdDate doubleValue]];
                cell.lblcomment1TimeAgo.text = [dateComment1 customTimeAgoString];
                
                NSDate *dateComment2 = [NSDate dateWithTimeIntervalSince1970:[commentDetail2.createdDate doubleValue]];
                cell.lblcomment2TimeAgo.text = [dateComment2 customTimeAgoString];
                
                
            }else{
                CommentDetail *commentDetail1 = [objfeed.commentDetail objectAtIndex:0];
                cell.lblCommentFullName1.text =commentDetail1.fullName;
                cell.lblcomment1.text =commentDetail1.comment;
                cell.lblcomment1.height = [commentDetail1.comment sizeForMaxWidth:_tblNewsFeed.width - 120 withFont:cell.lblcomment1.font].height;
                CGFloat maxComment1Height = ceil(cell.lblcomment1.font.lineHeight) * 2;
                if (cell.lblcomment1.height > maxComment1Height ) {
                    cell.lblcomment1.height = maxComment1Height;
                }
                //[cell.lblcomment1 sizeToFit];
                [cell.viewUser1 setHeight:cell.lblcomment1.bottom + 10];
                [cell.viewComment setHeight:cell.viewUser1.height];
                
                cell.viewUser2.hidden = YES;
                
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[commentDetail1.createdDate doubleValue]];
                cell.lblcomment1TimeAgo.text = [date customTimeAgoString];
            }
            if([objfeed.postImage isValid]) {
                cell.viewSeprator.hidden = TRUE;
                [cell.viewImg moveBottomOf:cell.viewData margin:0];
                [cell.viewLike moveBottomOf:cell.viewImg margin:0];
                [cell.viewComment moveBottomOf:cell.viewLike margin:0];
            }
            else {
                cell.viewSeprator.hidden = FALSE;
                [cell.viewSeprator moveBottomOf:cell.viewData margin:0];
                [cell.viewLike moveBottomOf:cell.viewData margin:0];
                [cell.viewComment moveBottomOf:cell.viewLike margin:0];
            }
            [cell.viewAllComment moveBottomOf:cell.viewComment margin:5];
            cell.viewMainDataContainer.height = ((objfeed.commentDetail.count>=2) ? cell.viewAllComment.bottom : cell.viewComment.bottom) + 10;
            
        }
    }
    
    [cell.viewAllComment whenTapped:^{
        [self viewAllcomments:objfeed];
    }];
    
    cell.lblCountLike.text = [NSString stringWithFormat:@"%@",objfeed.countLike];
    cell.lblCommentCount.text = [NSString stringWithFormat:@"%@",objfeed.countComment];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == arrNewsFeedList.count-1) {
        if(currentPageNumber < totalPages) {
            currentPageNumber++;
            if(_subscription) {
                [self getNewsFeedsWithSelectedCityWithCategoryId:category_Id];
            }
            else if(isSubscribedCity)
            {
                [self getNewsFeedsWithSelectedCityid:category_Id];
            }
            else {
                
                [self getNewsFeeds:category_Id location:selectedlocation];
            }
        }
        
        NSLog(@"Last cell");
    }
}





#pragma mark GetNewsFeed By Cityid and Catid (my profile newsfeed)

-(void)getNewsFeedsWithSelectedCityWithCategoryId:(NSString *)categoryId {
    
    if(currentPageNumber == 0) {
        currentPageNumber = 1;
        totalPages = 1;
    }
    if (currentPageNumber <= totalPages) {
        //2
        [SVProgressHUD show];
        NSDictionary *dictParam = @{@"user_id":user.userID,
                                    @"city_id":_subscription.cityId,
                                    @"page":@(currentPageNumber),
                                    @"category_id":categoryId ? : @""};
        
        [WebClient requestWithURL:URL_GET_POST_LIST_FROM_NEWSFEED parameters:dictParam  requestCompletionBlock:^(id responseObject, NSError *error) {
           
            _viewAddressPicker.hidden = NO;
            if (!error) {
                
                if(currentPageNumber == 1) {
                    [arrNewsFeedList removeAllObjects];
                }
                currentPageNumber++;
                totalPages = ceilf([responseObject[@"total_records"] floatValue] / [responseObject[@"page_limit"] floatValue]);
                totalRecords = [responseObject[@"total_records"] integerValue];
                //[arrNewsFeedList removeAllObjects];
                NSArray *responseArray = responseObject[kDataKey];
                
                if ([responseArray count]>0) {
                    [responseArray enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NewsFeed *objNewsFeed = [NewsFeed modelObjectWithDictionary:obj];
                        [arrNewsFeedList addObject:objNewsFeed];
                    }];
                }
                else{
                    
                }
                
            }else
            {
                [ToastView show:error.localizedDescription];
            }
            [_lblNoDataFound setHidden:[arrNewsFeedList count]];
            [_tblNewsFeed reloadData];
            [SVProgressHUD dismiss];
        }];
        
    }
}



#pragma mark GetnewsFeed From Current Location
-(void)getNewsFeeds :(NSString *)categoryId location:(CLLocation*)location;
{
    
    if(currentPageNumber == 0) {
        currentPageNumber = 1;
        totalPages = 1;
    }
    
    if(currentPageNumber == 1) {
       //3
         [SVProgressHUD show];
    }
    if(currentPageNumber <= totalPages) {
        NSDictionary *dictParam = @{@"user_id":user.userID,
                                    @"page":@(currentPageNumber),
                                    @"latitude":@(location.coordinate.latitude),
                                    @"longitude":@(location.coordinate.longitude),
                                    @"category_id":categoryId ? : @""};
        
        
        NSLog(@"dictParam%@",dictParam);
        
        [WebClient requestWithURL:URL_NEWS_FEED parameters:dictParam requestCompletionBlock:^(id responseObject, NSError *error) {
            [SVProgressHUD dismiss];
            _viewAddressPicker.hidden = NO;
            
            if (!error) {
                
                if(currentPageNumber == 1) {
                    [arrNewsFeedList removeAllObjects];
                }
                // currentPageNumber++;
                totalPages = ceilf([responseObject[@"total_records"] floatValue] / [responseObject[@"page_limit"] floatValue]);
                totalRecords = [responseObject[@"total_records"] integerValue];
                //[arrNewsFeedList removeAllObjects];
                NSArray *responseArray = responseObject[kDataKey];
                
                
                if (responseArray.count>0) {
                    [responseArray enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NewsFeed *objNewsFeed = [NewsFeed modelObjectWithDictionary:obj];
                        [arrNewsFeedList addObject:objNewsFeed];
                    }];
                }
                else{
                    
                    //[ToastView show:@"No records Found"];
                }
                
                
            }else
            {
                [ToastView show:error.localizedDescription];
            }
            [_lblNoDataFound setHidden:[arrNewsFeedList count]];
            [_tblNewsFeed reloadData];
            
        }];
    }
    else
    {
    }
}

#pragma mark Like Webservice

-(void)likeWebServiceCall:(NSNumber *)post_id SelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [SVProgressHUD show];
    [WebClient requestWithURL:URL_SEND_POST_LIKE parameters:@{@"user_id":user.userID, @"post_id": post_id} requestCompletionBlock:^(id responseObject, NSError *error){
        [SVProgressHUD dismiss];
        if (!error) {
            NewsFeed *newsfeed = [arrNewsFeedList objectAtIndex:indexPath.row];
            int number = [newsfeed.countLike intValue];
            if (newsfeed.likeStatus==1) {
                newsfeed.likeStatus = FALSE;
                number = number - 1;
                newsfeed.countLike = [NSNumber numberWithInt:number];
                
            }else {
                newsfeed.likeStatus = TRUE;
                number = number + 1;
                newsfeed.countLike = [NSNumber numberWithInt:number];
                
            }
            [arrNewsFeedList replaceObjectAtIndex:indexPath.row withObject:newsfeed];
            [_tblNewsFeed reloadData];
        }
        else
        {
            [ToastView show:error.localizedDescription];
        }
    }];
}

#pragma mark  Report Abuse Webservice Call

-(void)reportAbuseWebServiceCall:(NSNumber *)post_id SelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = @{@"user_id": user.userID,
                           @"post_id":post_id};
    [SVProgressHUD show];
    [WebClient requestWithURL:URL_SEND_REPORT_ABUSE parameters:dict requestCompletionBlock:^(id responseObject, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            NewsFeed *newsfeed = [arrNewsFeedList objectAtIndex:indexPath.row];
            
            if (newsfeed.report_abuse_post_status==1) {
                newsfeed.report_abuse_post_status = FALSE;
                
            }else {
                newsfeed.report_abuse_post_status = TRUE;
            }
            [arrNewsFeedList replaceObjectAtIndex:indexPath.row withObject:newsfeed];
            [_tblNewsFeed reloadData];
            [ToastView show:[responseObject valueForKey:@"message" ]];
        }
        else
        {
            [ToastView show:error.localizedDescription];
        }
    }];
}



#pragma mark GetSubscription List
-(void)getSubscriptionList
{
    NSDictionary *dictParam = @{@"user_id":user.userID};
    [WebClient requestWithURL:URL_SUBSCRIPTION_LIST parameters:dictParam  requestCompletionBlock:^(id responseObject, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            NSArray *responseArray = responseObject[kDataKey];
            arrsuburbData = responseObject[kDataKey];
            
           // [arrsuburbData insertObject:@"" atIndex:0];
            
            [responseArray enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                Subscription *objsubscription = [Subscription modelObjectWithDictionary:obj];
                [arrSubscriptionData addObject:objsubscription];
            }];
            
        }
        else
        {
            //[ToastView show:error.localizedDescription];
        }
        if (arrsuburbData.count>0) {
            imgViewrightArrowIcon.hidden = NO;
        }
        else{
            imgViewrightArrowIcon.hidden = YES;
        }
        
    }];
}



#pragma mark - Show SuburbPicker
- (void) showSuburbPicker {
    if (!self.pickerSuburb) {
        self.pickerSuburb = [[VTPickerView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height/3 - 64.0)];
    }
    NSMutableArray *arrStrings = [[arrsuburbData valueForKey:@"name"] mutableCopy];
    [arrStrings insertObject:@"Current Location" atIndex:0];
    self.pickerSuburb.isShowSearchBar = NO;
    [self.pickerSuburb setItemWithStringArray:arrStrings];
    [self.pickerSuburb showInView:self.view withDoneTappedBlock:^(PItem * obj) {
        
        isSubscribedCity = YES;
        if(obj.ID == 0) {
         
            currentPageNumber = 0;
            [self btnRefreshClick];
        }
        else {
            _lblAddress.text = obj.title;
            
            NSInteger objIndex = obj.ID  ;
            NSInteger arrayIndex = (objIndex)- 1 ;
            cityId = [[arrsuburbData objectAtIndex:arrayIndex] valueForKey:@"suburb_id"];
            currentPageNumber = 0;
            [self getNewsFeedsWithSelectedCityid:category_Id];
        }
        
        
    } withCancelTappedBlock:nil];
}


#pragma mark GetNewsFeed by subscribe City Id
-(void)getNewsFeedsWithSelectedCityid:(NSString *)categoryId {
    //1
    if(currentPageNumber == 0) {
        currentPageNumber = 1;
        totalPages = 1;
    }
    if(currentPageNumber == 1) {
        [SVProgressHUD show];
    }
    if (currentPageNumber <= totalPages) {
        
        NSDictionary *dictParam = @{@"user_id":user.userID,
                                    @"city_id":cityId,
                                    @"page":@(currentPageNumber),
                                    @"category_id":categoryId ? : @""};
        
        
        
        [WebClient requestWithURL:URL_GET_POST_LIST_FROM_NEWSFEED parameters:dictParam  requestCompletionBlock:^(id responseObject, NSError *error) {
            
            
            if (!error) {
                
                if(currentPageNumber == 1) {
                    [arrNewsFeedList removeAllObjects];
                }
                
                totalPages = ceilf([responseObject[@"total_records"] floatValue] / [responseObject[@"page_limit"] floatValue]);
                totalRecords = [responseObject[@"total_records"] integerValue];
                
                NSArray *responseArray = responseObject[kDataKey];
                if ([responseArray count]>0) {
                    [responseArray enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NewsFeed *objNewsFeed = [NewsFeed modelObjectWithDictionary:obj];
                        [arrNewsFeedList addObject:objNewsFeed];
                    }];
                }
                else{
                
                
                }
                
            }else
            {
                [ToastView show:error.localizedDescription];
            }
            [_lblNoDataFound setHidden:[arrNewsFeedList count]];
            [_tblNewsFeed reloadData];
            [SVProgressHUD dismiss];
        }];
        
    }
}


#pragma mark Share Post
- (void)shareText:(NSString *)text andUrl:(NSURL *)url
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (text) {
        [sharingItems addObject:text];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
    
}


#pragma mark viewallComments
-(void)viewAllcomments :(NewsFeed *)objFeed
{
    CommentViewcontroller *commentVC = [kStoryboard instantiateViewControllerWithIdentifier:@"CommentViewcontroller"];
    commentVC.objNewsFeed = objFeed;
    [self presentPopupViewController:commentVC animationType:MJPopupViewAnimationSlideBottomTop backgroundTouch:FALSE dismissed:^{
        if(commentVC.isCommentPosted) {
            [_tblNewsFeed reloadData];
        }
    }];
    
}

#pragma mark update Device Token
-(void)updateDeviceToken
{
    if ([NSStandardUserDefaults objectForKey:kDeviceToken]) {
        UIDevice *device = [UIDevice currentDevice];
        NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
        NSString *tokenString = [NSStandardUserDefaults objectForKey:kDeviceToken];
        NSDictionary *dictToken = @{@"device_token":tokenString,
                                    @"device_type":kDeviceType,
                                    @"user_id":[User loggedInUser].userID,
                                    @"device_id":currentDeviceId};
      [WebClient requestWithURL:URL_UPDATE_TOKEN parameters:dictToken requestCompletionBlock:^(id responseObject, NSError *error) {
            NSLog(@"Token :%@",responseObject);
        }];
        
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
