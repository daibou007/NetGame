//
//  XHBGomokuGameSencesViewController.m
//  XHBGomoku
//
//  Created by weqia on 14-9-1.
//  Copyright (c) 2014年 xhb. All rights reserved.
//

#import "XHBGomokuGameSencesViewController.h"
#import "XHBGomokuPieceView.h"
#import "HBPlaySoundUtil.h"
#import "UIColor+setting.h"
#import "XHBGomokuOverViewController.h"

#import "UIView+Toast.h"

@interface XHBGomokuGameSencesViewController ()
@property(nonatomic,weak)IBOutlet UIView * boardView;
@property(nonatomic,strong)XHBGomokuGameEngine * game;
@property(nonatomic,weak)IBOutlet UIButton * btnSound;
@property(nonatomic,weak)IBOutlet UIButton * btnUndo;
@property(nonatomic,weak)IBOutlet UIButton * btnRestart;
@property(nonatomic,weak)IBOutlet UILabel * blackChessMan;
@property(nonatomic,weak)IBOutlet UIImageView * piImgView;
@property(nonatomic,weak)IBOutlet UIView * topView;
@property(nonatomic)BOOL soundOpen;
@property(nonatomic,strong)NSMutableArray * pieces;
@property(nonatomic)NSInteger undoCount;
@property(nonatomic,strong)XHBGomokuPieceView * lastSelectPiece;

@end

@implementation XHBGomokuGameSencesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarHidden=YES;
    // Do any additional setup after loading the view.
    UITapGestureRecognizer * tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.boardView addGestureRecognizer:tap];
    self.game=[XHBGomokuGameEngine game];
    self.game.delegate=self;
    self.game.playerFirst=YES;
    self.view.backgroundColor=[UIColor colorWithIntegerValue:BACKGROUND_COLOR alpha:1];
    
    UIColor * color=[UIColor colorWithPatternImage:[UIImage imageNamed:@"topbarbg_2"]];
    self.topView.backgroundColor=color;
    self.blackChessMan.textColor=color;
    
    NSNumber* number=[[NSUserDefaults standardUserDefaults] objectForKey:@"soundOpen"];
    if (number) {
        [self.btnSound setSelected:!number.boolValue];
    }
    _pieces=[NSMutableArray array];
    number=[[NSUserDefaults standardUserDefaults] objectForKey:@"playerFirst"];
    if (number) {
        self.game.playerFirst=number.boolValue;
    }
    
    self.blackChessMan.text=@"未选择";
    [self.piImgView setHidden:YES];
    
    if ([NGGameNetManager instance].isClient) {
        [SVProgressHUD showProgress:-1 status:@"等待对方选择颜色"];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"选择颜色?"  delegate:nil cancelButtonTitle:@"黑" otherButtonTitles:@"白", nil] ;
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex){
            NSLog(@"index:%d",buttonIndex);
            if (buttonIndex == 0) {
                //黑
                NGGameChoosePole *netDate = [[NGGameChoosePole alloc] init];
                netDate.dataType = GAME_DATA_TYPE_CHOOSE_POLE;
                netDate.poleState = POLE_TYPE_BLACK;
                
                [self sendGameNetData:netDate];
                
                self.game.playerFirst=YES;
                self.blackChessMan.text=@"自己";
                [self.piImgView setHidden:NO];
                [self.piImgView setImage:[UIImage imageNamed:@"stone_black"]];
                
                NSNumber * number=[NSNumber numberWithBool:self.game.playerFirst];
                [[NSUserDefaults standardUserDefaults] setObject:number forKey:@"playerFirst"];
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self.game begin];
                });
            }else{
                //白
                NGGameChoosePole *netDate = [[NGGameChoosePole alloc] init];
                netDate.dataType = GAME_DATA_TYPE_CHOOSE_POLE;
                netDate.poleState = POLE_TYPE_WHITE;
                
                [self sendGameNetData:netDate];
                
                self.game.playerFirst = NO;
                self.blackChessMan.text= @"自己";
                [self.piImgView setHidden:NO];
                [self.piImgView setImage:[UIImage imageNamed:@"stone_white"]];
                
                NSNumber * number=[NSNumber numberWithBool:self.game.playerFirst];
                [[NSUserDefaults standardUserDefaults] setObject:number forKey:@"playerFirst"];
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self.game begin];
                    [SVProgressHUD showProgress:-1 status:@"等待对方!"];
                });
                

            }
        }];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)tapAction:(UITapGestureRecognizer*)tap
{
    CGPoint point=[tap locationInView:self.boardView];
    NSInteger tapRow=0;
    NSInteger tapLine=0;
    for (NSInteger row=1; row<=15; row++) {
        if (point.y>(21*(row-1)+3)&&point.y<(21*(row-1)+23)) {
            tapRow=row;
            break;
        }
    }
    for (NSInteger line=1; line<=15; line++) {
        if (point.x>(21*(line-1)+3)&&point.x<(21*(line-1)+23)) {
            tapLine=line;
            break;
        }
    }
    BOOL isOk = [self.game playerChessDown:tapRow line:tapLine];
    if (isOk) {
        NGGameStep *netDate = [[NGGameStep alloc] init];
        netDate.dataType = GAME_DATA_TYPE_MOVE_STEP;
        netDate.type = [[NSNumber alloc] initWithInt:self.game.playerFirst?POLE_TYPE_BLACK:POLE_TYPE_WHITE];
        netDate.tapRow = [[NSNumber alloc] initWithLong:tapRow];
        netDate.tapLine = [[NSNumber alloc] initWithLong:tapLine];
        
        [self sendGameNetData:netDate];
    }
}


-(IBAction)btnChangePlayChess:(id)sender
{
    if (self.game.gameStatu!=XHBGameStatuComputerChessing) {
        //send
        NGGameChoosePole *netDate = [[NGGameChoosePole alloc] init];
        netDate.dataType = GAME_DATA_TYPE_CHOOSE_POLE;
        netDate.poleState = POLE_TYPE_BLACK;
        
        [self sendGameNetData:netDate];
        
        self.game.playerFirst=YES;
        self.blackChessMan.text=@"自己";
        //TODO
        
        NSNumber * number=[NSNumber numberWithBool:self.game.playerFirst];
        [[NSUserDefaults standardUserDefaults] setObject:number forKey:@"playerFirst"];
        
                dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.game begin];
        });
        
    }
}

-(IBAction)btnBackAction:(id)sender
{}
-(IBAction)btnSoundAction:(id)sender
{
    self.btnSound.selected=!self.btnSound.selected;
    self.soundOpen=!self.btnSound.selected;
    NSNumber * number=[NSNumber numberWithBool:!self.btnSound.selected];
    [[NSUserDefaults standardUserDefaults] setObject:number forKey:@"soundOpen"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(IBAction)btnRestartAction:(id)sender
{
   //send restart gamedata
    NGGameReStart *restart = [[NGGameReStart alloc] init];
    restart.choice = GAME_RESTART_CHOICE_NONE;
    [self sendGameNetData:restart];
    [SVProgressHUD showProgress:-1 status:@"等待对方选择!"];
    
    
}
-(IBAction)btnUndoAction:(id)sender
{
    if ([self.game undo]) {
//        self.undoCount++;
        if (self.undoCount>=3) {
            self.btnUndo.enabled=NO;
            [self.btnUndo setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }else{
            self.btnUndo.enabled=YES;
            [self.btnUndo setTitleColor:[self.btnRestart titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
        }
        [self.btnUndo setTitle:[NSString stringWithFormat:@"UNDO(%ld)",(long)(3-self.undoCount)] forState:UIControlStateNormal];
    };
}


-(void)game:(XHBGomokuGameEngine*)game updateSences:(XHBGomokuChessPoint*)point
{
    XHBGomokuPieceView * view=[XHBGomokuPieceView piece:point];
    [self.boardView addSubview:view];
    [_pieces addObject:view];
    
    [view setSelected:YES];
    [self.lastSelectPiece setSelected:NO];
    self.lastSelectPiece=view;
}


-(void)game:(XHBGomokuGameEngine*)game finish:(BOOL)success
{
    
    NGGameOver *over = [[NGGameOver alloc] init];
    over.isSucess = success;
    over.successId = [NGGameNetManager instance].session.myPeerID.displayName;
    [self sendGameNetData:over];
    [SVProgressHUD dismiss];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.lastSelectPiece setSelected:NO];
        self.lastSelectPiece=nil;
        for (XHBGomokuChessPoint * point in game.chessBoard.successPoints) {
            for (XHBGomokuPieceView * view in self.pieces) {
                if (view.point==point) {
                    [view setSelected:YES];
                }
            }
        }
        XHBGomokuOverViewController * controller=[[XHBGomokuOverViewController alloc] initWithNibName:@"XHBGomokuOverViewController" bundle:nil];
                                                  
        controller.success=success;
        controller.backImage=[self  screenshot:[UIApplication sharedApplication].keyWindow];
        [controller setCallback:^{
//            [self.game reStart];
        }];
        [self presentViewController:controller animated:NO completion:nil];
    });
}

-(void)game:(XHBGomokuGameEngine*)game error:(XHBGameErrorType)errorType
{}

-(void)game:(XHBGomokuGameEngine*)game playSound:(XHBGameSoundType)soundType
{
    if (self.soundOpen) {
        if (soundType==XHBGameSoundTypeStep) {
            [[HBPlaySoundUtil shareForPlayingSoundEffectWith:@"down.wav"] play];
        }else if(soundType==XHBGameSoundTypeError){
            [[HBPlaySoundUtil shareForPlayingSoundEffectWith:@"lost.wav"] play];
        }else if(soundType==XHBGameSoundTypeFailed){
            [[HBPlaySoundUtil shareForPlayingSoundEffectWith:@"au_gameover.wav"] play];
        }else if(soundType==XHBGameSoundTypeVictory){
            [[HBPlaySoundUtil shareForPlayingSoundEffectWith:@"au_victory.wav"] play];
        }else if(soundType==XHBGameSoundTypeTimeOver){
            [[HBPlaySoundUtil shareForPlayingSoundEffectWith:@""] play];
        }
    }
}

-(void)game:(XHBGomokuGameEngine *)game statuChange:(XHBGameStatu)gameStatu
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (gameStatu == XHBGameStatuPlayChessing) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showInfoWithStatus:@"自己回合"];
        }else if(gameStatu == XHBGameStatuComputerChessing){
            [SVProgressHUD showProgress:-1 status:@"等待对方"];
        }
    });
}

-(void)gameRestart:(XHBGomokuGameEngine*)game
{
    self.undoCount=0;
    if (self.undoCount>=3) {
        self.btnUndo.enabled=NO;
        [self.btnUndo setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }else{
        self.btnUndo.enabled=YES;
        [self.btnUndo setTitleColor:[self.btnRestart titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    }
    [self.btnUndo setTitle:[NSString stringWithFormat:@"UNDO(%ld)",(long)(3-self.undoCount)] forState:UIControlStateNormal];
    for (XHBGomokuPieceView * view in self.pieces) {
        [view removeFromSuperview];
    }
    self.pieces=[NSMutableArray array];
}

-(void)game:(XHBGomokuGameEngine*)game undo:(XHBGomokuChessPoint*)point
{
    XHBGomokuPieceView * deleteView=nil;
    for (XHBGomokuPieceView * view in self.pieces) {
        if (view.point==point) {
            [view removeFromSuperview];
            deleteView=view;
        }
    }
    if (deleteView) {
        [self.pieces removeObject:deleteView];
    }
}

-(UIImage*)screenshot:(UIView*)view
{
    CGSize imageSize =view.bounds.size;
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    }
    else
    {
        UIGraphicsBeginImageContext(imageSize);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[view layer] renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark  NGGameNetProtocol

-(void)stopMatchmaking{
    
}
-(void)startMatchmaking{
    
}
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    if (state == MCSessionStateConnected) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
            [SVProgressHUD showInfoWithStatus:@"连接成功！！！"  maskType:SVProgressHUDMaskTypeBlack];
            [self dismissViewControllerAnimated:YES completion:nil];
        });

    } else if (state == MCSessionStateNotConnected) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
            [SVProgressHUD showInfoWithStatus:@"失去连接!"  maskType:SVProgressHUDMaskTypeBlack];
            [self dismissViewControllerAnimated:YES completion:nil];
        });

    }
}
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    
    GameData *gdata = [[GameData alloc] init];
    [gdata fromNSData:data];
    NSLog(@"REV NSDdata:type%d",gdata.dataType);
    
    if (gdata.dataType == GAME_DATA_TYPE_CHOOSE_POLE) {
        
        NGGameChoosePole *pole = [[NGGameChoosePole alloc] init];
        [pole fromNSData:data];
        
        if (pole.poleState == POLE_TYPE_BLACK) {
            self.game.playerFirst = NO;
        }else{
            self.game.playerFirst = YES;
        }
        
                dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (self.game.playerFirst) {
                self.blackChessMan.text=@"自己";
                [self.piImgView setHidden:NO];
                [self.piImgView setImage:[UIImage imageNamed:@"stone_black"]];
            }else{
                self.blackChessMan.text=@"自己";
                [self.piImgView setHidden:NO];
                [self.piImgView setImage:[UIImage imageNamed:@"stone_white"]];
                [SVProgressHUD showProgress:-1 status:@"等待对方!"];
            }
        });
        [self.game begin];
        
        
    }else if(gdata.dataType == GAME_DATA_TYPE_MOVE_STEP){
        
        NGGameStep *step = [[NGGameStep alloc] init];
        [step fromNSData:data];
        [self.game computerPrepareChess:step];

    }else if(gdata.dataType == GAME_DATA_TYPE_GAME_OVER){
        NGGameOver *over = [[NGGameOver alloc] init];
        [over fromNSData:data];
        NSString *myId =  [NGGameNetManager instance].session.myPeerID.displayName;
        if (![over.successId isEqual:myId]) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self game:self.game revFinish:!over.isSucess];
                [SVProgressHUD dismiss];
            });
        }
    }else if(gdata.dataType == GAME_DATA_TYPE_RESTART){
        [SVProgressHUD dismiss];
        NGGameReStart *restart = [[NGGameReStart alloc] init];
        [restart fromNSData:data];
        switch (restart.choice) {
            case GAME_RESTART_CHOICE_NONE:
            {
                       dispatch_async(dispatch_get_main_queue(), ^(void) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"开始新游戏?"  delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] ;
                    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex){
                         NSLog(@"index:%d",buttonIndex);
                        if (buttonIndex == 0) {
                            //NO
                            NGGameReStart *restart = [[NGGameReStart alloc] init];
                            restart.choice = GAME_RESTART_CHOICE_NO;
                        }else{
                            NGGameReStart *restart = [[NGGameReStart alloc] init];
                            restart.choice = GAME_RESTART_CHOICE_YES;
                            [self sendGameNetData:restart];
                            
                            [self.game reStart];
                        }
                    }];
               });
            }
                break;
            case GAME_RESTART_CHOICE_YES:{
                NSLog(@"GAME_RESTART_CHOICE_YES");
                   dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self.game reStart];
                    [SVProgressHUD showInfoWithStatus:@"请选择棋色"];
                      //TODO self.piImgView color
                  });
            }
                break;
                case GAME_RESTART_CHOICE_NO:
            {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [SVProgressHUD showInfoWithStatus:@"拒绝了新游戏"];
                    NSLog(@"GAME_RESTART_CHOICE_NO");
                });
            }
                break;
            default:
                break;
        }
        if (restart.choice) {
            
        }
    }
}

-(void) sendGameNetData:(GameData*)gdata{
    NSData *data = [gdata toNSData];
    NSError *error;
    
    [[NGGameNetManager instance].session sendData:data
                                          toPeers:[NGGameNetManager instance].session.connectedPeers
                                         withMode:MCSessionSendDataReliable
                                            error:&error];
    
}

-(void)game:(XHBGomokuGameEngine *)game revFinish:(BOOL)success{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.lastSelectPiece setSelected:NO];
        self.lastSelectPiece=nil;
        for (XHBGomokuChessPoint * point in game.chessBoard.successPoints) {
            for (XHBGomokuPieceView * view in self.pieces) {
                if (view.point==point) {
                    [view setSelected:YES];
                }
            }
        }
        XHBGomokuOverViewController * controller=[[XHBGomokuOverViewController alloc] initWithNibName:@"XHBGomokuOverViewController" bundle:nil];
        
        controller.success=success;
        controller.backImage=[self  screenshot:[UIApplication sharedApplication].keyWindow];
        [controller setCallback:^{
            [self btnRestartAction];
        }];
        [self presentViewController:controller animated:NO completion:nil];
    });
}

@end
