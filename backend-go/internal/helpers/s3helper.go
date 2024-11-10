package helpers

import (
	"fmt"
	"io"
	"mime/multipart"
	"path/filepath"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
)

type S3Client struct {
	BucketName  string
	Region      string
	ResourceURI string
}

/*
NewS3Client creates a new S3Client with the given bucket name, region, and resource URI.
*/
func NewS3Client(bucketName, region, resourceURI string) *S3Client {
	return &S3Client{
		BucketName:  bucketName,
		Region:      region,
		ResourceURI: resourceURI,
	}
}

/*
UploadImages uploads the given files to the S3 bucket and returns the URIs of the uploaded images.
*/
func (s *S3Client) UploadImages(files []*multipart.FileHeader, itemID int, itemType string) ([]string, error) {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(s.Region),
	})
	if err != nil {
		return nil, fmt.Errorf("unable to create session: %v", err)
	}

	uploader := s3manager.NewUploader(sess)

	var images []io.Reader
	var filenames []string

	for _, file := range files {
		f, err := file.Open()
		if err != nil {
			return nil, fmt.Errorf("unable to open file: %v", err)

		}
		defer f.Close()
		images = append(images, f)
		filenames = append(filenames, file.Filename)

	}

	var uris []string

	for i, image := range images {
		if i >= len(filenames) {
			return nil, fmt.Errorf("filename missing for image at index %d", i)
		}

		key := fmt.Sprintf("%s/%d/%d_%s", itemType, itemID, i, filepath.Base(filenames[i]))
		uri := s.ResourceURI + key
		uris = append(uris, uri)

		_, err = uploader.Upload(&s3manager.UploadInput{
			Bucket: aws.String(s.BucketName),
			Key:    aws.String(key),
			Body:   image,
		})
		if err != nil {
			return nil, fmt.Errorf("unable to upload %q to %q: %v", filenames[i], s.BucketName, err)
		}

		fmt.Printf("Successfully uploaded %q to %q\n", filenames[i], s.BucketName)
	}
	return uris, nil
}

/*
DeleteImages deletes the images with the given URIs from the S3 bucket.
*/
func (s *S3Client) DeleteImages(uris []string) error {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(s.Region),
	})
	if err != nil {
		return fmt.Errorf("unable to create session: %v", err)
	}

	deleter := s3manager.NewBatchDelete(sess)

	objects := make([]s3manager.BatchDeleteObject, len(uris))
	for i, uri := range uris {
		objects[i] = s3manager.BatchDeleteObject{
			Object: &s3.DeleteObjectInput{
				Bucket: aws.String(s.BucketName),
				Key:    aws.String(uri),
			},
		}
	}

	err = deleter.Delete(aws.BackgroundContext(), &s3manager.DeleteObjectsIterator{
		Objects: objects,
	})
	if err != nil {
		return fmt.Errorf("unable to delete objects from S3: %v", err)
	}

	return nil
}
