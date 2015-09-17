//
//  MusicPlayerView+TableView.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 4/21/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

extension MusicPlayerViewController {
    // MARK: - TableView
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : SongTableViewCell = tableView.dequeueReusableCellWithIdentifier("SongCell", forIndexPath: indexPath) as! SongTableViewCell
        var videoObject:SongModel = dataSource[indexPath.row] as! SongModel
        cell.sttLabel.text = String(indexPath.row)
        cell.songTitle.text = videoObject.Title as String
        cell.singerLabel.text = videoObject.Artist as String
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.songSource = self.dataSource[indexPath.row] as! SongModel
        self.bufferSong(self.songSource.Link320)
        self.songTitle.text = (songSource.Title as String)+" - "+(songSource.Artist as String)
        self.songTitleMini.text = self.songTitle.text
        segmentView.selectSegmentAtIndex(0)
        resetTimer()
        player.play()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.loadLyric()
        })
        
        
    }
}
