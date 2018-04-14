//
//  GCDTableVC.swift
//  ThreadForiOS
//
//  Created by Ronan on 4/14/18.
//  Copyright © 2018 RonanStudio. All rights reserved.
//

import UIKit

class GCDTableVC: UITableViewController {

    var indicatorView: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicatorView.color = .green
        indicatorView.center = view.center
        view.addSubview(indicatorView)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        let combo = (section, row)
        switch combo {
        case (0, 0):
            let serialQueue = DispatchQueue(label: "anything")
            for i in 0...3 {
                executeSync(queue: serialQueue, message: "串行同步 \(i)")
            }
        case (0, 1):
            let concurrentQueue = DispatchQueue(label: "anything", attributes: .concurrent)
            for i in 0...3 {
                executeSync(queue: concurrentQueue, message: "并发同步 \(i)")
            }
        case (0, 2):
            for i in 0...3 {
                //会导致死锁，程序崩溃
                executeSync(queue: .main, message: "主队列同步 \(i)")
            }
        case (1, 0):
            let serialQueue = DispatchQueue(label: "anything")
            for i in 0...3 {
                executeAsync(queue: serialQueue, message: "串行异步 \(i)")
            }
        case (1, 1):
            let concurrentQueue = DispatchQueue(label: "anything", attributes: .concurrent)
            for i in 0...3 {
                executeAsync(queue: concurrentQueue, message: "并发异步 \(i)")
            }
        case (1, 2):
            print("")
            for i in 0...3 {
                executeAsync(queue: .main, message: "主队列异步 \(i)")
            }
        case (2, 0):
            testGCDThreadCommunication()
        case (2, 1):
            testBarrier()
        case (2, 2):
            testGroup()
        default:
            print("not gonna happen")
        }
    }
    
    //同步执行
    func executeSync(queue: DispatchQueue, message: String) {
        queue.sync {
            print("\(message), \(Thread.current)")
        }
    }
    
    //异步执行
    func executeAsync(queue: DispatchQueue, message: String) {
        queue.async {
            print("\(message), \(Thread.current)")
        }
    }
    
    func testGCDThreadCommunication() {
        indicatorView.startAnimating()
        DispatchQueue.global().async {
            //睡眠3s 假装执行耗时任务，如下载
            Thread.sleep(forTimeInterval: 3)
            
            //不放主线程，会导致程序崩溃
            //                self.indicatorView.stopAnimating()
            
            //主线程，操作UI相关
            DispatchQueue.main.async {
                self.indicatorView.stopAnimating()
            }
        }
    }
    
    func testBarrier() {
        let concurrentQueue = DispatchQueue(label: "anything you like", attributes: .concurrent)
        for i in 0...2 {
            executeAsync(queue: concurrentQueue, message: "栅栏之前：并发异步 \(i)")
        }
        
        //设置栅栏
        concurrentQueue.async(flags: .barrier) {
            print("我就是传说中的栅栏")
        }
        
        for i in 0..<2 {
            executeAsync(queue: concurrentQueue, message: "栅栏之后：并发异步 \(i)")
        }
    }
    
    func testGroup() {
        let concurrentQueue = DispatchQueue(label: "anything you like", attributes: .concurrent)
        let group = DispatchGroup()
        concurrentQueue.async(group: group, qos: .default, flags: []) {
            print("任务 1")
        }
        concurrentQueue.async(group: group, qos: .default, flags: []) {
            print("任务 2")
        }
        concurrentQueue.async(group: group, qos: .default, flags: []) {
            print("任务 3")
        }
        concurrentQueue.async(group: group, qos: .default, flags: []) {
            print("任务 4")
        }
        group.notify(queue: concurrentQueue) {
            print("老板，所有任务都做完啦！")
        }
    }
}
