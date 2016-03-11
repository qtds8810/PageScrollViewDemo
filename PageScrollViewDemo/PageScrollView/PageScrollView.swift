//
//  PageScrollView.swift
//  PageScrollViewDemo
//
//  Created by zhaoyou on 16/3/11.
//  Copyright © 2016年 zhaoyouwang. All rights reserved.
//

import UIKit

/// 全局的时间间隔
let duration: NSTimeInterval = 3.0

class PageScrollView: UIView {

    /// 闭包传值---点击事件
    var clickCurrentImageClosure: ((currentIndxe: Int) -> Void)?
    /// 图片数组,如果数据源改变，则需要改变scrollView、分页指示器的数量
    var imageArray: [UIImage!]! {
        didSet {
            contentScrollView.scrollEnabled = !(imageArray.count == 1)
            pageIndicator.frame = CGRectMake(frame.width - 20 * CGFloat(imageArray.count), frame.height - 30, 20 * CGFloat(imageArray.count), 20)
            pageIndicator.numberOfPages = imageArray.count
            setScrollViewOfImage()
        }
    }
    /// 图片链接，这里用了强制拆包，所以不要把urlImageArray设为nil
    var urlImageArray: [String]? {
        didSet {
            for urlStr in urlImageArray! {
                guard let urlImage = NSURL(string: urlStr) else {
                    break
                }
                guard let dataImage = NSData(contentsOfURL: urlImage) else {
                    break
                }
                guard let tempImage = UIImage(data: dataImage) else {
                    break
                }
                
                imageArray.append(tempImage)
            }
        }
    }
    /// 当前显示的第几张图片
    var indexOfCurrentImage: Int!  {
        //监听显示的第几张图片，来更新分页指示器
        didSet {
            pageIndicator.currentPage = indexOfCurrentImage
        }
    }
    /// 添加时间控制
    var timer: NSTimer?
    
    //MARK: View LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, imagesArray: [UIImage!]?, imageClick: (pageIndex: Int) -> Void) {
        self.init(frame: frame)
        
        imageArray = imagesArray
        clickCurrentImageClosure = imageClick
        
        // 默认显示第一张图片
        indexOfCurrentImage = 0
        setUpCircleView()
    }
    
    //MARK: Initialization
    private func setUpCircleView() {
        // 0.特殊属性设置
        contentScrollView.contentSize = CGSizeMake(frame.width * 3, 0)
        contentScrollView.scrollEnabled = !(imageArray.count == 1)
        contentScrollView.setContentOffset(CGPointMake(frame.width, 0), animated: false)
        pageIndicator.numberOfPages = imageArray.count
        
        // 1.添加子控件
        addSubview(contentScrollView)
        contentScrollView.addSubview(currentImageView)
        contentScrollView.addSubview(lastImageView)
        contentScrollView.addSubview(nextImageView)
        addSubview(pageIndicator)
        
        // 2.布局子控件
        contentScrollView.frame = CGRectMake(0, 0, frame.width, frame.height)
        currentImageView.frame = CGRectMake(frame.width, 0, frame.width, 200)
        lastImageView.frame = CGRectMake(0, 0, frame.width, 200)
        nextImageView.frame = CGRectMake(frame.width * 2, 0, frame.width, 200)
        pageIndicator.frame = CGRectMake(frame.width - 20 * CGFloat(imageArray.count), frame.height - 30, 20 * CGFloat(imageArray.count), 20)
        
        // 3.添加点击事件
        let imageTap = UITapGestureRecognizer(target: self, action: Selector("imageTapAction:"))
        currentImageView.addGestureRecognizer(imageTap)
        
        // 4.设置计时器
        timer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: "timerAction", userInfo: nil, repeats: true)
        
        setScrollViewOfImage()
    }
    
    //MARK: 设置图片
    private func setScrollViewOfImage() {
        currentImageView.image = imageArray[indexOfCurrentImage]
        nextImageView.image = imageArray[getNextImageIndex(indexOfCurrentImage)]
        lastImageView.image = imageArray[getLastImageIndex(indexOfCurrentImage)]
    }
    
    // 得到上一张图片的下标
    private func getLastImageIndex(index: Int) -> Int {
        let tempIndex = index - 1
        return tempIndex == -1 ? (imageArray.count - 1) : (tempIndex)
    }
    
    // 得到下一张图片的下标
    private func getNextImageIndex(index: Int) -> Int {
        let tempIndex = index + 1
        return tempIndex < imageArray.count ? tempIndex : 0
    }
    
    //MARK: Action
    //事件触发方法
    func timerAction() {
        contentScrollView.setContentOffset(CGPointMake(frame.width*2, 0), animated: true)
    }
    //MARK: 闭包
    func imageTapAction(tap: UITapGestureRecognizer){
        clickCurrentImageClosure!(currentIndxe: indexOfCurrentImage)
    }
    
    //MARK: 懒加载
    /// 创建内容滚动视图
    private lazy var contentScrollView: UIScrollView = {
        let sc = UIScrollView()
        sc.bounces = false
        sc.pagingEnabled = true
        sc.showsHorizontalScrollIndicator = false
        sc.delegate = self
        return sc
    }()
    /// 创建当前图片
    private lazy var currentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.userInteractionEnabled = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    /// 创建最后一张图片
    private lazy var lastImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    /// 创建下一张图片
    private lazy var nextImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    /// 创建分页指示器
    private lazy var pageIndicator: UIPageControl = {
        let control = UIPageControl()
        control.hidesForSinglePage = true
        control.backgroundColor = UIColor.clearColor()
        return control
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PageScrollView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        timer?.invalidate()
        timer = nil
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //如果用户手动拖动到了一个整数页的位置就不会发生滑动了 所以需要判断手动调用滑动停止滑动方法
        if !decelerate {
            scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        if offset == 0 {
            indexOfCurrentImage = getLastImageIndex(indexOfCurrentImage)
        }else if offset == frame.width * 2 {
            indexOfCurrentImage = getNextImageIndex(indexOfCurrentImage)
        }
        // 重新布局图片
        setScrollViewOfImage()
        //布局后把contentOffset设为中间
        scrollView.setContentOffset(CGPointMake(frame.width, 0), animated: false)
        
        //重置计时器
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: "timerAction", userInfo: nil, repeats: true)
        }
    }
    //时间触发器 设置滑动时动画true，会触发的方法
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(contentScrollView)
    }
}
