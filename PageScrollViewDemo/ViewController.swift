//
//  ViewController.swift
//  PageScrollViewDemo
//
//  Created by zhaoyou on 16/3/11.
//  Copyright © 2016年 zhaoyouwang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var pageScrollView: PageScrollView!
    
    //MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.title = "无限循环滚动图片demo"
        
        setupUI()
    }

    //MARK: Initialization
    private func setupUI() {
        automaticallyAdjustsScrollViewInsets = false
        let imageArray: [UIImage!] = [UIImage(named: "first.jpg"),UIImage(named: "second.jpg"),UIImage(named: "third.jpg"),UIImage(named: "second.jpg")]
        pageScrollView = PageScrollView(frame: CGRectMake(0, 64, self.view.frame.size.width, 200), imagesArray: imageArray, imageClick: { (pageIndex) -> Void in
            print("第\(pageIndex)张图片点击")
        })
        pageScrollView.backgroundColor = UIColor.yellowColor()
        view.addSubview(pageScrollView)
        view.addSubview(addBtn)
        
        addBtn.frame = CGRect(x: 0, y: 300, width: UIScreen.mainScreen().bounds.width, height: 35)
    }
    
    //MARK: Action
    func appendImage() {
        pageScrollView.urlImageArray = ["http://pic1.nipic.com/2008-09-08/200898163242920_2.jpg"]
    }

    //MARK: 懒加载
    private lazy var addBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("添加图片", forState: UIControlState.Normal)
        btn.backgroundColor = UIColor.brownColor()
        btn.addTarget(self , action: "appendImage", forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
}

