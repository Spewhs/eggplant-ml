from db.NoDocument import NoDocument
from dto.CreateClassifierParam import create_default_classifier_param
from model.Classifier import Classifier
from db import DB_URL, DB_PORT, DATABASE_NAME, CLASSIFIER_COLLECTION, _create_collection_instance
from bson.objectid import ObjectId


def store_object_in_mongo(model) -> Classifier:
    collection = _create_collection_instance(DB_URL, DB_PORT, DATABASE_NAME, CLASSIFIER_COLLECTION)
    params = create_default_classifier_param(model)
    info = collection.insert_one(vars(params))
    return Classifier.from_create_param(info.inserted_id, params)


def load_object_from_mongo(_id) -> Classifier:
    collection = _create_collection_instance(DB_URL, DB_PORT, DATABASE_NAME, CLASSIFIER_COLLECTION)
    data = collection.find_one({"_id": ObjectId(_id)})

    try:
        classifier = Classifier.from_json(data)
    except UnboundLocalError as e:
        raise NoDocument("No model with this id")
    return classifier
