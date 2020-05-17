import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:blooprtest/profile_pages/base_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blooprtest/auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:blooprtest/config.dart';
import 'package:http/http.dart' as http;

abstract class BaseBackend {
  Future<DocumentSnapshot> getSingleImageURL();
  Future<QuerySnapshot> getMultipleImageURL(int number);
  Future<QuerySnapshot> getExplorePosts(int numberOfPosts);
  Future<http.Response> getRecommendedPostIDs();
  Future<List<Future<DocumentSnapshot>>> getRecommendedPosts();
  Future<List<Future<DocumentSnapshot>>> getSentPosts(); // returns the posts specified in the user's inbox as a List of DocumentSnapshots, and clears the inbox
  Future<List<String>> getSeenPosts(); // gets the IDs of all posts the user has interacted with from elasticsearch
  Future<QuerySnapshot> getImageComments(String postID);
  Future<String> getFirestoreUserID(String userID);
  Future<String> getOwnUserID();
  Future<String> getOwnFirestoreUserID();
  Future<String> getNickname(String userID);
  Future<String> getOwnEmail();
  Future<DocumentSnapshot> getUser(String userFirestoreID);
  Future<DocumentSnapshot> getPost(String postFirestoreID);
  Future<QuerySnapshot> getUserPosts(String userID);
  Future<QuerySnapshot> getUserSaveInteractions(String userID);
  Future<QuerySnapshot> getOwnPosts();
  Future<QuerySnapshot> getUserFollowers(String userFirestoreID);
  Future<QuerySnapshot> getUserFollowing(String userFirestoreID);
  Future<QuerySnapshot> getDiscoverFriends(int number);
  Future<List<Map>> getSearchResults(String searchText);
  Future<Uint8List> getProfilePicture(String userID);
  Future<Uint8List> getProfilePictureFromFirestoreID(String userFirestoreID);
  Future<Uint8List> getImageFromLocation(String imageLocation);
  Future<Uint8List> getImageFromPostID(String postID);
  Future<QuerySnapshot> getFollowingFromFirestoreID(String userFirestoreID);
  void postUserComment(String postID, String text);
  void addCommentLike(String parentPostID, String commentID);
  void removeCommentLike(String parentPostID, String commentID);
  void addLike(String postID);
  void addDislike(String postID);
  void addSaveAndLike(String postID);
  void addFollow(String userFirestoreID);
  void unfollow(String userFirestoreID);
  void uploadProfilePicture(File image);
  void updateProfile(String newNickname, String newBio);
  void uploadPost(File image, String caption, List<String> tags);
  void unsavePost(String postFirestoreID);
  void sendMeme(String userFirestoreID, String postID);
  void reportMeme(String postID);
}

class Backend implements BaseBackend {
  final _firestore = Firestore.instance;
  final _firebaseStorage = FirebaseStorage.instance;
  final _auth = Auth();

  // debug level is similar to verbosity
  // change to 0 to print nothing to the console
  // 1 to print when functions are invoked
  // 2 to print all non-future results (and 1)
  // 3 to print all results (and 2)
  final int debugLevel = 1;

  Future<DocumentSnapshot> getSingleImageURL() {
    DocumentReference singleImageReference = _firestore.collection('posts').document('hBt3chrf1CU5YqSqg9sP');
    return singleImageReference.get();
  }

  Future<QuerySnapshot> getMultipleImageURL(int number) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getMultipleImageURL");
    }

    Query imageQuery = _firestore.collection('posts').orderBy('caption').limit(number);
    return imageQuery.getDocuments();
  }

  Future<QuerySnapshot> getExplorePosts(int numberOfPosts) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getExplorePosts");
    }

    Future<QuerySnapshot> postSnapshot = _firestore.collection('posts').orderBy('caption').limit(numberOfPosts).getDocuments();
    return postSnapshot;
  }

  Future<http.Response> getRecommendedPostIDs() async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getRecommendedPostIDs");
    }

    String firestoreID = await getOwnFirestoreUserID();
    var likedPostsUrl = 'https://7ee3335fb14040269b50b807934bf5d0.europe-west2.gcp.elastic-cloud.com:9243/interactions/_doc/$firestoreID/_source';
    var likedPostsResponse = await http.get(likedPostsUrl, headers: {'Authorization':'Basic ZWxhc3RpYzpGcWFweTJhSFRnOGo4QWlSa3Z1NDR4aTA='});
    List likedPosts = json.decode(likedPostsResponse.body)['likes'];
    List viewedPosts = json.decode(likedPostsResponse.body)['viewedPosts'];

    String likedPostsString;

    if(likedPosts.length != 0) {
      likedPostsString = '[';
      for (int counter = 0; counter < likedPosts.length - 1; counter++) {
        likedPostsString = likedPostsString + '"${likedPosts[counter]}",';
      }
      likedPostsString =
          likedPostsString + '"${likedPosts[likedPosts.length - 1]}"]';
    } else {
      likedPostsString = '[]';
    }

    String viewedPostsString;

    if(viewedPosts.length != 0) {
      viewedPostsString = '[';
      for (int counter = 0; counter < viewedPosts.length - 1; counter++) {
        viewedPostsString = viewedPostsString + '"${viewedPosts[counter]}",';
      }
      viewedPostsString =
          viewedPostsString + '"${viewedPosts[viewedPosts.length - 1]}"]';
    } else {
      viewedPostsString = '[]';
    }

    var url = 'https://7ee3335fb14040269b50b807934bf5d0.europe-west2.gcp.elastic-cloud.com:9243/interactions/_search';
    var body = '{ "query": { "terms": { "likes": $likedPostsString, "boost": 1.0 } }, "aggs": { "likedPosts": { "terms": { "field": "likes", "exclude": $viewedPostsString, "min_doc_count": 1 } }, "viewedPosts": { "terms": { "field": "viewedPosts", "exclude": $viewedPostsString, "min_doc_count": 1 } }, "unique_posts": { "cardinality": { "field": "likes" } } } }';
    return http.post(url, body: body, headers: {'Authorization':'Basic ZWxhc3RpYzpGcWFweTJhSFRnOGo4QWlSa3Z1NDR4aTA=','Content-Type': 'application/json'});
  }

  Future<List<Future<DocumentSnapshot>>> getRecommendedPosts() async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getRecommendedPosts");
    }

    return getRecommendedPostIDs().then((response) async {
      List buckets = json.decode(response.body)['aggregations']['likedPosts']['buckets'];
      print("recommended posts: " + buckets.toString());

      List<String> documentIDs = [];
      for(int counter = 0; counter < buckets.length; counter++) {
        documentIDs.add(buckets[counter]['key']);
      }

      List<Future<DocumentSnapshot>> postFutures = [];

      for (int counter = 0; counter < documentIDs.length; counter++) {
        postFutures.add(_firestore.collection('posts').document(documentIDs[counter]).get());
      }
      
      postFutures.add(_firestore.collection('posts').document('HFnzAFhgMVeZ4o3fYivn').get());
      postFutures.add(_firestore.collection('posts').document('M3V2BGoZ6DPV8drjvQ8V').get());
      postFutures.add(_firestore.collection('posts').document('S6Ovx4oh2VwnnsKIicVk').get());
      postFutures.add(_firestore.collection('posts').document('TVF2h9bfBDV0pvLvcWdV').get());
      postFutures.add(_firestore.collection('posts').document('W3GW6KIVYtjWnqhpy755').get());

      return postFutures;
    });
  }

  Future<List<Future<DocumentSnapshot>>> getSentPosts() async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getSentPosts");
    }

    String firestoreID = await getOwnFirestoreUserID();
    return _firestore.collection('users').document(firestoreID).get().then((userDocument) {
      List<Map> sentPosts = userDocument.data['inbox'];
      List<Future<DocumentSnapshot>> futureDocumentSnapshots = [];

      if(sentPosts != null) {
        _firestore.collection('users').document(firestoreID).updateData({
          'inbox': FieldValue.arrayRemove(sentPosts)
        });

        for (int counter = 0; counter < sentPosts.length; counter++) {
          futureDocumentSnapshots.add(getPost(sentPosts[counter]['postID']));
        }
      }
      return futureDocumentSnapshots;
    });
  }

  Future<List<String>> getSeenPosts() async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getSeenPosts");
    }

    String firestoreID = await getOwnFirestoreUserID();
    var userInteractionsUrl = 'https://7ee3335fb14040269b50b807934bf5d0.europe-west2.gcp.elastic-cloud.com:9243/interactions/_doc/$firestoreID/_source';
    return http.get(userInteractionsUrl, headers: {'Authorization':'Basic ZWxhc3RpYzpGcWFweTJhSFRnOGo4QWlSa3Z1NDR4aTA='}).then((response) {
      List<String> viewedPosts = json.decode(response.body)['viewedPosts'];
      return viewedPosts;
    });
}

  Future<QuerySnapshot> getImageComments(String postID) { // TODO: add limit to the number of comments downloaded at once - perhaps learn how to paginate
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getImageComments");
      print("[FUNCTION ARGS][Backend.getImageComments] postID: $postID");
    }

    Query commentsQuery = _firestore.collection('posts').document(postID).collection('comments');
    return commentsQuery.getDocuments();
  }

  Future<String> getFirestoreUserID(String userID) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getFirestoreUserID");
      print("[FUNCTION ARGS][Backend.getFirestoreUserID] userID: $userID");
    }

    QuerySnapshot querySnapshot = await _firestore.collection('users').where("userID", isEqualTo: userID).getDocuments();

    if(debugLevel >= 2) {
      print("[FUNCTION OUTPUT][Backend.getFirestoreUserID] firestoreUserID: ${querySnapshot.documents[0].documentID}");
    }

    return querySnapshot.documents[0].documentID;
  }

  Future<String> getOwnUserID() {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getOwnUserID");
    }

    if(debugLevel >= 2) {
      print("[FUNCTION OUTPUT][Backend.getOwnUserID] ownUserID: ${_auth.currentUser()}");
    }

    return _auth.currentUser();
  }

  Future<String> getOwnFirestoreUserID() async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getOwnFirestoreUserID");
    }

    String userID = await _auth.currentUser();
    return getFirestoreUserID(userID);
  }

  Future<String> getNickname(String userFirestoreID) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getNickname");
      print("[FUNCTION ARGS][Backend.getNickname] userFirestoreID: $userFirestoreID");
    }

    DocumentSnapshot userSnapshot = await _firestore.collection('users').document(userFirestoreID).get();

    if(debugLevel >= 2) {
      print("[FUNCTION OUTPUT][Backend.getFirestoreUserID] userNickname: ${userSnapshot.data["nickname"]}");
    }

    return userSnapshot.data['nickname'];
  }

  Future<String> getOwnEmail() {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getOwnEmail");
    }

    if(debugLevel >= 2) {
      print("[FUNCTION OUTPUT][Backend.getOwnEmail] ownEmail: ${_auth.currentUserEmail()}");
    }

    return _auth.currentUserEmail();
  }

  Future<DocumentSnapshot> getUser(String userFirestoreID) {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getUser");
      print("[FUNCTION ARGS][Backend.getUser] userFirestoreID: $userFirestoreID");
    }

    Future<DocumentSnapshot> userSnapshot = _firestore.collection('users').document(userFirestoreID).get();
    return userSnapshot;
  }

  Future<DocumentSnapshot> getPost(String postFirestoreID) {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getPost");
      print("[FUNCTION ARGS][Backend.getPost] postFirestoreID: $postFirestoreID");
    }

    Future<DocumentSnapshot> postSnapshot = _firestore.collection('posts').document(postFirestoreID).get();
    return postSnapshot;
  }
  
  Future<QuerySnapshot> getUserPosts(String userID) {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getUserPosts");
      print("[FUNCTION ARGS][Backend.getUserPosts] userID: $userID");
    }

    Future<QuerySnapshot> query = _firestore.collection('posts').where('posterID', isEqualTo: userID).getDocuments();
    return query;
  }

  Future<QuerySnapshot> getUserSaveInteractions(String userFirestoreID) {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getUserSaveInteractions");
      print("[FUNCTION ARGS][Backend.getUserSaveInteractions] userFirestoreID: $userFirestoreID");
    }

    Future<QuerySnapshot> saveInteractions = _firestore.collection('users').document(userFirestoreID).collection('interactions').where('save', isEqualTo: true).getDocuments();
    return saveInteractions;
  }

  Future<QuerySnapshot> getOwnPosts() async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getOwnPosts");
    }

    String userID = await _auth.currentUser();
    Future<QuerySnapshot> query = _firestore.collection('posts').where("posterID", isEqualTo: userID).getDocuments();
    return query;
  }

  Future<QuerySnapshot> getUserFollowers(String userFirebaseID) {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getUserFollowers");
      print("[FUNCTION ARGS][Backend.getUserFollowers] userFirebaseID: $userFirebaseID");
    }

    Future<QuerySnapshot> followersQuery = _firestore.collection('users').document(userFirebaseID).collection('followers').getDocuments();
    return followersQuery;
  }

  Future<QuerySnapshot> getUserFollowing(String userFirebaseID) {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getUserFollowing");
      print("[FUNCTION ARGS][Backend.getUserFollowing] userFirebaseID: $userFirebaseID");
    }

    Future<QuerySnapshot> followingQuery = _firestore.collection('users').document(userFirebaseID).collection('following').getDocuments();
    return followingQuery;
  }
  
  Future<QuerySnapshot> getDiscoverFriends(int number) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getDiscoverFriends");
      print("[FUNCTION ARGS][Backend.getDiscoverFriends] number: ${number.toString()}");
    }

    String userID = await _auth.currentUser();
    //Future<QuerySnapshot> query = _firestore.collection('users').where("userID", isGreaterThan: userID).where("userID", isLessThan: userID).limit(number).getDocuments();
    Future<QuerySnapshot> query = _firestore.collection('users').limit(number).getDocuments();
    return query;
  }

  Future<List<Map>> getSearchResults(String searchText) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getSearchResults");
      print("[FUNCTION ARGS][Backend.getSearchResults] searchText: $searchText");
    }

    var searchUrl = 'https://7ee3335fb14040269b50b807934bf5d0.europe-west2.gcp.elastic-cloud.com:9243/users/_search';
    var body = '{"query": {"match" : {"nickname" : {"query" : "$searchText","fuzziness": "AUTO"}}}}';
    return http.post(searchUrl, body: body, headers: {'Authorization':'Basic ZWxhc3RpYzpGcWFweTJhSFRnOGo4QWlSa3Z1NDR4aTA=','Content-Type': 'application/json'})
      .then((response) {
        List searchResults = json.decode(response.body)["hits"]["hits"];
        List<Map> searchResultsMap = [];
        for (int counter = 0; counter < searchResults.length; counter++) {
          Map resultMap = {
            'firestoreID': searchResults[counter]["_source"]["userID"],
            'nickname': searchResults[counter]["_source"]["nickname"]
          };
          searchResultsMap.add(resultMap);
        }
        if(debugLevel >= 2) {
          print("[FUNCTION OUTPUT][Backend.getSearchResults] searchResultsMap: ${searchResultsMap.toString()}");
        }
        return searchResultsMap;
    });
  }
  
  Future<Uint8List> getProfilePicture(String userID) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getProfilePicture");
      print("[FUNCTION ARGS][Backend.getProfilePicture] userID: $userID");
    }

    String userFirestoreID = await getFirestoreUserID(userID);
    DocumentSnapshot userDocument = await _firestore.collection('users').document(userFirestoreID).get();
    StorageReference imageReference = await _firebaseStorage.getReferenceFromUrl(userDocument.data['profile picture URL']);
    return imageReference.getData(Constants.MAX_IMAGE_SIZE);
  }

  Future<Uint8List> getProfilePictureFromFirestoreID(String userFirestoreID) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getProfilePictureFromFirestoreID");
      print("[FUNCTION ARGS][Backend.getProfilePictureFromFirestoreID] userFirestoreID: $userFirestoreID");
    }

    DocumentSnapshot userDocument = await _firestore.collection('users').document(userFirestoreID).get();
    StorageReference imageReference = await _firebaseStorage.getReferenceFromUrl(userDocument.data['profile picture URL']);
    return imageReference.getData(Constants.MAX_IMAGE_SIZE);
  }

  Future<Uint8List> getImageFromLocation(String imageLocation) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getImageFromLocation");
      print("[FUNCTION ARGS][Backend.getImageFromLocation] imageLocation: $imageLocation");
    }

    if(imageLocation == null) {
      return null;
    } else {
      StorageReference imageReference = await _firebaseStorage
          .getReferenceFromUrl(imageLocation);
      return imageReference.getData(Constants.MAX_IMAGE_SIZE);
    }
  }

  Future<Uint8List> getImageFromPostID(String postID) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getImageFromPostID");
      print("[FUNCTION ARGS][Backend.getImageFromPostID] postID: $postID");
    }

    DocumentSnapshot postDocument = await _firestore.collection('posts').document(postID).get();
    return getImageFromLocation(postDocument.data['imageURL']);
  }

  Future<QuerySnapshot> getFollowingFromFirestoreID(String userFirestoreID) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.getFollowingFromFirestoreID");
      print("[FUNCTION ARGS][Backend.getFollowingFromFirestoreID] userFirestoreID: $userFirestoreID");
    }

    String ownFirestoreID = await getOwnFirestoreUserID();
    Future<QuerySnapshot> followingSnapshot = _firestore.collection('users').document(ownFirestoreID).collection('following').where("user firebaseID", isEqualTo: userFirestoreID).getDocuments();
    return followingSnapshot;
  }

  void postUserComment(String postID, String text) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.postUserComment");
      print("[FUNCTION ARGS][Backend.postUserComment] postID: $postID, text: $text");
    }

    String userID = await _auth.currentUser();
    String firestoreUserID = await getFirestoreUserID(userID);
    String nickname = await getNickname(firestoreUserID);
    _firestore.collection('posts').document(postID).collection('comments').add({
      'commenter name': nickname,
      'commenterID': firestoreUserID,
      'likes': [],
      'text': text
    });  // TODO: add .catchError() to postUserComment
  }

  void addCommentLike(String parentPostID, String commentID) {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.addCommentLike");
      print("[FUNCTION ARGS][Backend.addCommentLike] parentPostID: $parentPostID, commentID: $commentID");
    }

    getOwnFirestoreUserID().then((userFirestoreID) {
      _firestore.collection('posts').document(parentPostID).collection('comments').document(commentID).updateData({
        'likes': FieldValue.arrayUnion([userFirestoreID])
      });
    }); // TODO: add .catchError()to addCommentLike
  }
  
  void removeCommentLike(String parentPostID, String commentID) {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.removeCommentLike");
      print("[FUNCTION ARGS][Backend.removeCommentLike] parentPostID: $parentPostID, commentID: $commentID");
    }

    getOwnFirestoreUserID().then((userFirestoreID) {
      _firestore.collection('posts').document(parentPostID).collection('comments').document(commentID).updateData({
        'likes': FieldValue.arrayRemove([userFirestoreID])
      }); // TODO: add .catchError() to remove commentlike
    });
  }

  void addLike(String postID) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.addLike");
      print("[FUNCTION ARGS][Backend.addLike] postID: $postID");
    }

    String userID = await _auth.currentUser();
    String firestoreUserID = await getFirestoreUserID(userID);
    _firestore.collection('users').document(firestoreUserID).collection('interactions').add({
      'postID': postID,
      'like': true,
      'dislike': false,
      'save': false
    }); // TODO: add .catchError() to addLike
  }

  void addDislike(String postID) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.addDislike");
      print("[FUNCTION ARGS][Backend.addDislike] postID: $postID");
    }

    String userID = await _auth.currentUser();
    String firestoreUserID = await getFirestoreUserID(userID);
    _firestore.collection('users').document(firestoreUserID).collection('interactions').add({
      'postID': postID,
      'like': false,
      'dislike': true,
      'save': false
    }); // TODO: add .catchError() to addDislike
  }

  void addSaveAndLike(String postID) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.addSaveAndLike");
      print("[FUNCTION ARGS][Backend.addSaveAndLike] postID: $postID");
    }

    String userID = await _auth.currentUser();
    String firestoreUserID = await getFirestoreUserID(userID);
    _firestore.collection('users').document(firestoreUserID).collection('interactions').add({
      'postID': postID,
      'like': true,
      'dislike': false,
      'save': true
    });
  }

  void addFollow(String userFirestoreID) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.addFollow");
      print("[FUNCTION ARGS][Backend.addFollow] userFirestoreID: $userFirestoreID");
    }

    String ownFirestoreID = await getOwnFirestoreUserID();
    DocumentSnapshot ownDocument = await _firestore.collection('users').document(ownFirestoreID).get();
    DocumentSnapshot userDocument = await _firestore.collection('users').document(userFirestoreID).get();
    _firestore.collection('users').document(userFirestoreID).collection('followers').add({
      'userFirestoreID': ownDocument.documentID,
      'user nickname': ownDocument.data['nickname'],
      'user profile picture URL': ownDocument.data['profile picture URL']
    }); // TODO: add .catchError() to addfollow
    _firestore.collection('users').document(ownFirestoreID).collection('following').add({
      'userFirestoreID': userDocument.documentID,
      'user nickname': userDocument.data['nickname'],
      'user profile picture URL': userDocument.data['profile picture URL']
    });
  }

  void unfollow(String userFirestoreID) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.unfollow");
      print("[FUNCTION ARGS][Backend.unfollow] userFirestoreID: $userFirestoreID");
    }

    String ownFirestoreID = await getOwnFirestoreUserID();
    QuerySnapshot followerSnapshot = await _firestore.collection('users').document(userFirestoreID).collection('followers').where("userFirestoreID", isEqualTo: ownFirestoreID).getDocuments();
    QuerySnapshot followingSnapshot = await _firestore.collection('users').document(ownFirestoreID).collection('following').where("userFirestoreID", isEqualTo: userFirestoreID).getDocuments();
    if(followingSnapshot.documents.length > 0) { //TODO: split this statement up
      _firestore.collection('users').document(userFirestoreID).collection(
          'followers')
          .document(followerSnapshot.documents[0].documentID)
          .delete();
    } // TODO: add .catchError() to unfollow
    if (followerSnapshot.documents.length > 0) {
      _firestore.collection('users').document(ownFirestoreID).collection(
          'following')
          .document(followingSnapshot.documents[0].documentID)
          .delete();
    }
  }
  
  void uploadProfilePicture(File image) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.uploadProfilePicture");
      print("[FUNCTION ARGS][Backend.uploadProfilePicture] image: ${image.toString()}");
    }

    String userID = await getOwnUserID();
    StorageReference storageReference = _firebaseStorage.ref().child('user/images/$userID/${basename(image.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.onComplete;
    String imageURL = await storageReference.getDownloadURL();
    String firestoreUserID = await getFirestoreUserID(userID);
    _firestore.collection('users').document(firestoreUserID).updateData({'profile picture URL': imageURL}); // TODO: add addOnSuccessListener and addOnFailureListener
  }
  
  void updateProfile(String newNickname, String newBio) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.updateProfile");
      print("[FUNCTION ARGS][Backend.updateProfile] newNickname: $newNickname, newBio: $newBio");
    }

    String firebaseID = await getOwnFirestoreUserID();
    _firestore.collection('users').document(firebaseID).updateData({'nickname': newNickname, 'user bio': newBio}); // TODO: add addOnSuccessListener and addOnFailureListener to updateProfile
  }

  void uploadPost(File image, String caption, List<String> tags) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.uploadPost");
      print("[FUNCTION ARGS][Backend.uploadPost] image: ${image.toString()}, caption: $caption, tags: ${tags.toString()}");
    }

    String userID = await getOwnUserID();
    StorageReference storageReference = _firebaseStorage.ref().child(
        'user/images/$userID/${basename(image.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.onComplete;
    String imageURL = await storageReference.getDownloadURL();
    String firestoreUserID = await getFirestoreUserID(userID);
    String nickName = await getNickname(firestoreUserID);
    _firestore.collection('posts').add({
      'caption': caption,
      'poster name': nickName,
      'posterID': userID,
      'posterFirestoreID': firestoreUserID,
      'date posted': FieldValue.serverTimestamp(),
      'imageURL': imageURL,
      'likes': 0,
      'dislikes': 0,
      'saves': 0,
      'tags': tags
    }); // TODO: add onSuccess and onFailure listeners to uploadPost
  }
  
  void unsavePost(String postFirestoreID) async {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.unsavePost");
      print("[FUNCTION ARGS][Backend.unsavePost] postFirestoreID: $postFirestoreID");
    }

    String userFirestoreID = await getOwnFirestoreUserID();
    QuerySnapshot postInteractionSnapshot = await _firestore.collection('users').document(userFirestoreID).collection('interactions').where('postID',isEqualTo: postFirestoreID).limit(1).getDocuments();
    if(postInteractionSnapshot.documents.length > 0) {
      String interactionID = postInteractionSnapshot.documents[0].documentID;
      _firestore.collection('users').document(userFirestoreID).collection('interactions').document(interactionID).updateData({'save':false});
    }
  }

  void sendMeme(String userFirestoreID, String postID) {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.sendMeme");
      print("[FUNCTION ARGS][Backend.sendMeme] userFirestoreID: $userFirestoreID, postID: $postID");
    }

    Map sendMap = ({'postID':postID,'senderID':userFirestoreID});
    _firestore.collection('users').document(userFirestoreID).updateData({
      'inbox': FieldValue.arrayUnion([sendMap])
    });
  }

  void reportMeme(String postID) {
    if(debugLevel >= 1) {
      print("[FUNCTION INVOKED] Backend.reportMeme");
      print("[FUNCTION ARGS][Backend.reportMeme] postID: $postID");
    }

    // TODO: implement report feature
  }
}
