    //
//  HomeCell.swift
//  gamves
//
//  Created by Jose Vigil on 6/19/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import Floaty

    class HomeCell: BaseCell, UIPageViewControllerDataSource, UIPageViewControllerDelegate, CellDelegate {     
    
    var homeController: HomeController?
    
    var pages = [UIViewController]()
    
    var pageController : UIPageViewController?
    
    var categoryHomePage:CategoryHomePage!
    var categoryPage:CategoryPage!
    var fanpagePage:FanpagePage!
    
    var index = Int()     

    var floaty = Floaty(size: 80)  
    
    override func setupViews() {
        super.setupViews()   

        self.pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil) 
        self.pageController!.dataSource = self       
        self.pageController!.delegate = self
        
        self.categoryHomePage = CategoryHomePage()
        self.categoryHomePage.delegate = self
        
        self.categoryPage = CategoryPage()
        self.categoryPage.delegate = self
        
        self.fanpagePage = FanpagePage()
        self.fanpagePage.delegate = self
        let initialPage = 0     

        self.pages.append(self.categoryHomePage)
        self.pages.append(self.categoryPage)
        self.pages.append(self.fanpagePage)      
        
        self.pageController?.setViewControllers([self.pages[initialPage]], direction: .forward, animated: true, completion: nil)
        
        self.pageController!.view.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height);    

        self.addSubview((self.pageController?.view)!)

        self.removeSwipeGesture()             

        //FLOATY      

        self.floaty.paddingY = 35
        self.floaty.paddingX = 20                    
        self.floaty.itemSpace = 30
        self.floaty.shadowRadius = 20
        self.floaty.buttonColor = UIColor.gamvesYellowColor
        var addImage = UIImage(named: "add_symbol")
        addImage = addImage?.maskWithColor(color: UIColor.white)
        addImage = Global.resizeImage(image: addImage!, targetSize: CGSize(width:40, height:40))
        self.floaty.buttonImage = addImage
        self.floaty.sizeToFit()

        //floaty.verticalDirection = .down        
        
        let itemNewFanpage = FloatyItem()
        var likeImage = UIImage(named: "like")
        likeImage = likeImage?.maskWithColor(color: UIColor.white)
        itemNewFanpage.icon = likeImage                   
        itemNewFanpage.buttonColor = UIColor.gamvesYellowColor
        itemNewFanpage.titleLabelPosition = .left
        itemNewFanpage.titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20)
        itemNewFanpage.title = "NEW FANPAGE"
        itemNewFanpage.handler = { item in
            
            if self.homeController != nil
            {
                self.homeController?.addNewFanpage(edit:false)
            }

        }

        let itemNewVideo = FloatyItem()
        var videoImage = UIImage(named: "video")
        videoImage = videoImage?.maskWithColor(color: UIColor.white)
        itemNewVideo.icon = videoImage  
        itemNewVideo.buttonColor = UIColor.gamvesYellowColor
        itemNewVideo.titleLabelPosition = .left
        itemNewVideo.titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20)
        itemNewVideo.title = "NEW VIDEO"
        itemNewVideo.handler = { item in
            
            if self.homeController != nil {

                self.homeController?.addNewVideo()
            }

        }

        self.floaty.addItem(item: itemNewFanpage)       
        self.floaty.addItem(item: itemNewVideo)       
        self.addSubview(floaty)            

        NotificationCenter.default.addObserver(self, selector: #selector(setLastFanpage), name: NSNotification.Name(rawValue: Global.notificationKeyReloadPageFanpage), object: nil)
        
        Global.pagesPageView = self.pages        
    }
        
    func setFanpageHomeController(homeController: HomeController) {
        self.fanpagePage.homeController = homeController
    }

    func removeSwipeGesture() {

        for view in self.pageController!.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = false
            }
        }
    }
    
  
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let viewControllerIndex = self.pages.index(of: viewController) {
            if viewControllerIndex == 0 {
                // wrap to last page in array
                return self.pages.last
            } else {
                // go to previous page in array
                return self.pages[viewControllerIndex - 1]
            }
        }
        return nil
    }
            
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            
        if let viewControllerIndex = self.pages.index(of: viewController) {
            if viewControllerIndex < self.pages.count - 1 {
                // go to next page in array
                return self.pages[viewControllerIndex + 1]
            } else {
                // wrap to first page in array
                return self.pages.first
            }
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
    
    }

    func scrollToViewController(viewController: UIViewController,
                                direction: UIPageViewControllerNavigationDirection, data: AnyObject?)
    {
        
        pageController?.setViewControllers([viewController],
            direction: direction,
            animated: true,
            completion: { (finished) -> Void in
                             
                if data != nil 
                {
                    if (data?.isKind(of: GamvesCategory.self))!
                    {
                            print("category")
                        
                            let category = viewController as! CategoryPage                        
                        
                            category.categoryGamves = data as! GamvesCategory
                        
                            category.setCategoryData()                            
                        
                    } else if (data?.isKind(of: GamvesFanpage.self))!
                    {
                        print("fanpage")
                        
                        let fanpagePage = viewController as! FanpagePage
                        
                        let fanpage = data as! GamvesFanpage
                        
                        //print(fanpage.fanpageObj?.objectId)
                        
                        fanpagePage.setFanpageGamvesData(data: fanpage)
                        
                        fanpagePage.setFanpageData()                        

                    }
                }
        })
        
    }
    
    

        @objc func setLastFanpage() {       
        
        self.pageController?.setViewControllers([self.pages[0]], direction: .forward, animated: true, completion: nil)
    }

    
    func setCurrentPage(current: Int, direction: Int, data: AnyObject?)
    {        

        var navDirection = UIPageViewControllerNavigationDirection(rawValue: 0)
        
        if direction == 1 {

            navDirection = .forward

        } else if direction == -1 {

            navDirection = .reverse
        }
        
        scrollToViewController(viewController: pages[current], direction: navDirection!, data: data)
        
        self.pageController?.setViewControllers([self.pages[current]], direction: navDirection!, animated: true, completion: nil)
    }


    
    
}


