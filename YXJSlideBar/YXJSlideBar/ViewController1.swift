//
//  TableViewController.swift
//  YXJSlideBarTest
//
//  Created by yuanxiaojun on 16/8/10.
//  Copyright © 2016年 袁晓钧. All rights reserved.
//

import UIKit
import YXJSlideBar

class ViewController1: UIViewController, YXJSlideContentViewDataSource {

    private var slideBar: YXJSlideBar!

    private var contentView: YXJSlideContentView!

    private var vcs = [
        UIViewController(), UIViewController(),
        UIViewController(), UIViewController(),
        UIViewController(), UIViewController(),
        UIViewController(), UIViewController(),
        UIViewController(), UIViewController()]

    override func viewDidLoad() {
        super.viewDidLoad()

        // 菜单2
        self.slideBar = YXJSlideBar(frame: CGRect(x: 0, y: 50, width: ScreenWidth, height: 50))
        self.slideBar.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.slideBar.itemsTitle = ["选项1", "选项2", "选项3", "选项4", "选项5", "选项6", "选项7", "选项8", "选项9", "选项10"]
        self.slideBar.itemColor = UIColor.grayColor()
        self.slideBar.itemSelectedColor = UIColor.redColor()
        self.slideBar.sliderColor = UIColor.redColor()
        self.slideBar.slideBarItemSelectedCallback { [weak self](idx) -> Void in
            print(idx)
            self?.contentView.scrollSlideContentViewToIndex(idx)
        }
        self.view.addSubview(self.slideBar)

        self.contentView = YXJSlideContentView(frame: CGRect(x: 0, y: 100, width: ScreenWidth, height: 300))
        self.contentView.dataSource = self
        self.contentView.setIsEnableScroll(true)
        self.contentView.slideContentViewScrollFinished { [weak self](idx) in
            print(idx)
            self?.slideBar.selectSlideBarItemAtIndex(idx)
        }
        self.view.addSubview(contentView)

        vcs[0].view.backgroundColor = UIColor.redColor()
        vcs[1].view.backgroundColor = UIColor.blackColor()
        vcs[2].view.backgroundColor = UIColor.darkGrayColor()
        vcs[3].view.backgroundColor = UIColor.lightGrayColor()
        vcs[4].view.backgroundColor = UIColor.greenColor()
        vcs[5].view.backgroundColor = UIColor.blueColor()
        vcs[6].view.backgroundColor = UIColor.cyanColor()
        vcs[7].view.backgroundColor = UIColor.yellowColor()
        vcs[8].view.backgroundColor = UIColor.magentaColor()
        vcs[9].view.backgroundColor = UIColor.orangeColor()
    }

    // MARK:YXJSlideContentViewDataSource
    func slideContentView(contentView: YXJSlideContentView!, viewControllerForIndex index: UInt) -> UIViewController! {
        return vcs[Int(index)]
    }
    func numOfContentView() -> Int {
        return vcs.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
