//
//  ImageUploader.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/04.
//

import FirebaseStorage

struct ImageUploader {
    //MARK: 画像のアップロード
    //(/profileimage/...に画像がアップロードされ、imageUrlを返す)
    static func uploadImage(image:UIImage,completion:@escaping(String)->Void){
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {return}
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error{
                print("DEBUG: 画像のアップロードに失敗 -> \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL { url, error in
                guard let imageUrl = url?.absoluteString else {return}
                completion(imageUrl)
            }
        }
    }
}

