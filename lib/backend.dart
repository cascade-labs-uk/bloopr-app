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
  Future<List<Future<DocumentSnapshot>>> getSentPosts();
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
}

class Backend implements BaseBackend {
  final _firestore = Firestore.instance;
  final _firebaseStorage = FirebaseStorage.instance;
  final _auth = Auth();

  Future<DocumentSnapshot> getSingleImageURL() {
    DocumentReference singleImageReference = _firestore.collection('posts').document('hBt3chrf1CU5YqSqg9sP');
    return singleImageReference.get();
  }

  Future<QuerySnapshot> getMultipleImageURL(int number) async {
    Query imageQuery = _firestore.collection('posts').orderBy('caption').limit(number);
    return imageQuery.getDocuments();
  }

  Future<QuerySnapshot> getExplorePosts(int numberOfPosts) async {
    Future<QuerySnapshot> postSnapshot = _firestore.collection('posts').orderBy('caption').limit(numberOfPosts).getDocuments();
    return postSnapshot;
  }

  Future<http.Response> getRecommendedPostIDs() async {
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

  Future<QuerySnapshot> getImageComments(String postID) { // TODO: add limit to the number of comments downloaded at once - perhaps learn how to paginate
    Query commentsQuery = _firestore.collection('posts').document(postID).collection('comments');
    return commentsQuery.getDocuments();
  }

  Future<String> getFirestoreUserID(String userID) async {
    QuerySnapshot querySnapshot = await _firestore.collection('users').where("userID", isEqualTo: userID).getDocuments();
    return querySnapshot.documents[0].documentID;
  }

  Future<String> getOwnUserID() {
    return _auth.currentUser();
  }

  Future<String> getOwnFirestoreUserID() async {
    String userID = await _auth.currentUser();
    return getFirestoreUserID(userID);
  }

  Future<String> getNickname(String userFirestoreID) async {
    DocumentSnapshot userSnapshot = await _firestore.collection('users').document(userFirestoreID).get();
    return userSnapshot.data['nickname'];
  }

  Future<String> getOwnEmail() {
    return _auth.currentUserEmail();
  }

  Future<DocumentSnapshot> getUser(String userFirestoreID) {
    Future<DocumentSnapshot> userSnapshot = _firestore.collection('users').document(userFirestoreID).get();
    return userSnapshot;
  }

  Future<DocumentSnapshot> getPost(String postFirestoreID) {
    Future<DocumentSnapshot> postSnapshot = _firestore.collection('posts').document(postFirestoreID).get();
    return postSnapshot;
  }
  
  Future<QuerySnapshot> getUserPosts(String userID) {
    Future<QuerySnapshot> query = _firestore.collection('posts').where("userID", isEqualTo: userID).getDocuments();
    return query;
  }

  Future<QuerySnapshot> getUserSaveInteractions(String userFirestoreID) {
    Future<QuerySnapshot> saveInteractions = _firestore.collection('users').document(userFirestoreID).collection('interactions').where('save', isEqualTo: true).getDocuments();
    return saveInteractions;
  }

  Future<QuerySnapshot> getOwnPosts() async {
    String userID = await _auth.currentUser();
    Future<QuerySnapshot> query = _firestore.collection('posts').where("posterID", isEqualTo: userID).getDocuments();
    return query;
  }

  Future<QuerySnapshot> getUserFollowers(String userFirebaseID) {
    Future<QuerySnapshot> followersQuery = _firestore.collection('users').document(userFirebaseID).collection('followers').getDocuments();
    return followersQuery;
  }

  Future<QuerySnapshot> getUserFollowing(String userFirebaseID) {
    Future<QuerySnapshot> followingQuery = _firestore.collection('users').document(userFirebaseID).collection('following').getDocuments();
    return followingQuery;
  }
  
  Future<QuerySnapshot> getDiscoverFriends(int number) async {
    String userID = await _auth.currentUser();
    //Future<QuerySnapshot> query = _firestore.collection('users').where("userID", isGreaterThan: userID).where("userID", isLessThan: userID).limit(number).getDocuments();
    Future<QuerySnapshot> query = _firestore.collection('users').limit(number).getDocuments();
    return query;
  }

  Future<List<Map>> getSearchResults(String searchText) async {
    print("getting search results");
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
        print("final search results:" + searchResultsMap.toString());
        return searchResultsMap;
    });
  }
  
  Future<Uint8List> getProfilePicture(String userID) async {
    String userFirestoreID = await getFirestoreUserID(userID);
    DocumentSnapshot userDocument = await _firestore.collection('users').document(userFirestoreID).get();
    StorageReference imageReference = await _firebaseStorage.getReferenceFromUrl(userDocument.data['profile picture URL']);
    return imageReference.getData(Constants.MAX_IMAGE_SIZE);
  }

  Future<Uint8List> getProfilePictureFromFirestoreID(String userFirestoreID) async {
    DocumentSnapshot userDocument = await _firestore.collection('users').document(userFirestoreID).get();
    StorageReference imageReference = await _firebaseStorage.getReferenceFromUrl(userDocument.data['profile picture URL']);
    return imageReference.getData(Constants.MAX_IMAGE_SIZE);
  }

  Future<Uint8List> getImageFromLocation(String imageLocation) async {
    StorageReference imageReference = await _firebaseStorage.getReferenceFromUrl(imageLocation);
    return imageReference.getData(Constants.MAX_IMAGE_SIZE);
  }

  Future<Uint8List> getImageFromPostID(String postID) async {
    DocumentSnapshot postDocument = await _firestore.collection('posts').document(postID).get();
    return getImageFromLocation(postDocument.data['imageURL']);
  }

  Future<QuerySnapshot> getFollowingFromFirestoreID(String userFirestoreID) async {
    String ownFirestoreID = await getOwnFirestoreUserID();
    Future<QuerySnapshot> followingSnapshot = _firestore.collection('users').document(ownFirestoreID).collection('following').where("user firebaseID", isEqualTo: userFirestoreID).getDocuments();
    return followingSnapshot;
  }

  void postUserComment(String postID, String text) async {
    String userID = await _auth.currentUser();
    String firestoreUserID = await getFirestoreUserID(userID);
    String nickname = await getNickname(firestoreUserID);
    _firestore.collection('posts').document(postID).collection('comments').add({
      'commenter name': nickname,
      'commenterID': firestoreUserID,
      'likes': [],
      'text': text
    });
  }

  void addCommentLike(String parentPostID, String commentID) {
    getOwnFirestoreUserID().then((userFirestoreID) {
      _firestore.collection('posts').document(parentPostID).collection('comments').document(commentID).updateData({
        'likes': FieldValue.arrayUnion([userFirestoreID])
      });
    });
  }
  
  void removeCommentLike(String parentPostID, String commentID) {
    void addCommentLike(String parentPostID, String commentID) {
      getOwnFirestoreUserID().then((userFirestoreID) {
        _firestore.collection('posts').document(parentPostID).collection('comments').document(commentID).updateData({
          'likes': FieldValue.arrayRemove([userFirestoreID])
        });
      });
    }
  }

  void addLike(String postID) async {
    String userID = await _auth.currentUser();
    String firestoreUserID = await getFirestoreUserID(userID);
    _firestore.collection('users').document(firestoreUserID).collection('interactions').add({
      'postID': postID,
      'like': true,
      'dislike': false,
      'save': false
    });
  }

  void addDislike(String postID) async {
    String userID = await _auth.currentUser();
    String firestoreUserID = await getFirestoreUserID(userID);
    _firestore.collection('users').document(firestoreUserID).collection('interactions').add({
      'postID': postID,
      'like': false,
      'dislike': true,
      'save': false
    });
  }

  void addSaveAndLike(String postID) async {
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
    String ownFirestoreID = await getOwnFirestoreUserID();
    DocumentSnapshot ownDocument = await _firestore.collection('users').document(ownFirestoreID).get();
    DocumentSnapshot userDocument = await _firestore.collection('users').document(userFirestoreID).get();
    _firestore.collection('users').document(userFirestoreID).collection('followers').add({
      'userFirestoreID': ownDocument.documentID,
      'user nickname': ownDocument.data['nickname'],
      'user profile picture URL': ownDocument.data['profile picture URL']
    });
    _firestore.collection('users').document(ownFirestoreID).collection('following').add({
      'userFirestoreID': userDocument.documentID,
      'user nickname': userDocument.data['nickname'],
      'user profile picture URL': userDocument.data['profile picture URL']
    });
  }

  void unfollow(String userFirestoreID) async {
    String ownFirestoreID = await getOwnFirestoreUserID();
    QuerySnapshot followerSnapshot = await _firestore.collection('users').document(userFirestoreID).collection('followers').where("userFirestoreID", isEqualTo: ownFirestoreID).getDocuments();
    QuerySnapshot followingSnapshot = await _firestore.collection('users').document(ownFirestoreID).collection('following').where("userFirestoreID", isEqualTo: userFirestoreID).getDocuments();
    if(followingSnapshot.documents.length > 0) { //TODO: split this statement up
      _firestore.collection('users').document(userFirestoreID).collection(
          'followers')
          .document(followerSnapshot.documents[0].documentID)
          .delete();
    }
    if (followerSnapshot.documents.length > 0) {
      _firestore.collection('users').document(ownFirestoreID).collection(
          'following')
          .document(followingSnapshot.documents[0].documentID)
          .delete();
    }
  }
  
  void uploadProfilePicture(File image) async {
    String userID = await getOwnUserID();
    StorageReference storageReference = _firebaseStorage.ref().child('user/images/$userID/${basename(image.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.onComplete;
    String imageURL = await storageReference.getDownloadURL();
    String firestoreUserID = await getFirestoreUserID(userID);
    _firestore.collection('users').document(firestoreUserID).updateData({'profile picture URL': imageURL}); // TODO: add addOnSuccessListener and addOnFailureListener
  }
  
  void updateProfile(String newNickname, String newBio) async {
    String firebaseID = await getOwnFirestoreUserID();
    _firestore.collection('users').document(firebaseID).updateData({'nickname': newNickname, 'user bio': newBio}); // TODO: add addOnSuccessListener and addOnFailureListener
  }

  void uploadPost(File image, String caption, List<String> tags) async {
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
    });
  }
  
  void unsavePost(String postFirestoreID) async {
    String userFirestoreID = await getOwnFirestoreUserID();
    QuerySnapshot postInteractionSnapshot = await _firestore.collection('users').document(userFirestoreID).collection('interactions').where('postID',isEqualTo: postFirestoreID).limit(1).getDocuments();
    if(postInteractionSnapshot.documents.length > 0) {
      String interactionID = postInteractionSnapshot.documents[0].documentID;
      _firestore.collection('users').document(userFirestoreID).collection('interactions').document(interactionID).updateData({'save':false});
    }
  }

  void sendMeme(String userFirestoreID, String postID) {
    Map sendMap = ({'postID':postID,'senderID':userFirestoreID});
    _firestore.collection('users').document(userFirestoreID).updateData({
      'inbox': FieldValue.arrayUnion([sendMap])
    });
  }
}
