//
//  AddRecordViewController.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 06/01/2021.
//

import UIKit

class AddRecordViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func newVc(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
   
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController: "AddExpenseViewController"),
                self.newVc(viewController: "AddIncomeViewController")]
    } ()
    
    
    

    
    var pageControl = UIPageControl()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        self.dataSource = self
        self.delegate = self
        configurePageControl()
        // This sets up the first view that will show up on our page control
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
            }
        
        
        }
    
    //******************************************************************
    //MARK: PageVC Related code
    //******************************************************************
        
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
               return nil
           }
           
           let previousIndex = viewControllerIndex - 1
           
           // User is on the first view controller and swiped left to loop to
           // the last view controller.
           guard previousIndex >= 0 else {
//               return orderedViewControllers.last
               // Uncommment the line below, remove the line above if you don't want the page control to loop.
                return nil
           }
           
           guard orderedViewControllers.count > previousIndex else {
               return nil
           }
           
           return orderedViewControllers[previousIndex]
       }
       
       func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
               return nil
           }
           
           let nextIndex = viewControllerIndex + 1
           let orderedViewControllersCount = orderedViewControllers.count
           
           // User is on the last view controller and swiped right to loop to
           // the first view controller.
           guard orderedViewControllersCount != nextIndex else {
               return orderedViewControllers.first
               // Uncommment the line below, remove the line above if you don't want the page control to loop.
               // return nil
           }
           
           guard orderedViewControllersCount > nextIndex else {
               return nil
           }
           
           return orderedViewControllers[nextIndex]
       }
    
    //***********************************************
    //MARK: Setup dots on VC programmatically
    //***********************************************
    func configurePageControl() {
        //Total number of pages that are available is based on how manu available colors we have
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 110, width: UIScreen.main.bounds.width, height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        self.pageControl.pageIndicatorTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        self.view.addSubview(pageControl)
    }
    
    // MARK: Delegate functions
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.firstIndex(of: pageContentViewController)!
    }
}
