package services

import (
	"bytes"
	"fmt"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
)

type S3Service struct {
	s3Client *s3.S3
	bucketName string
}

func NewS3Service(region, bucketName string) (*S3Service, error) {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
	})
	if err != nil {
		return nil, fmt.Errorf("failed to create AWS session: %v", err)
	}

	return &S3Service{
		s3Client:   s3.New(sess),
		bucketName: bucketName,
	}, nil
}

func (s *S3Service) GeneratePresignedURL(key string, contentType string, expirationTime time.Duration) (string, error) {
	req, _ := s.s3Client.PutObjectRequest(&s3.PutObjectInput{
		Bucket:      aws.String(s.bucketName),
		Key:         aws.String(key),
		ContentType: aws.String(contentType),
	})

	url, err := req.Presign(expirationTime)
	if err != nil {
		return "", fmt.Errorf("failed to generate pre-signed URL: %v", err)
	}

	return url, nil
}

func (s *S3Service) UploadFile(key string, fileContent []byte, contentType string) error {
	_, err := s.s3Client.PutObject(&s3.PutObjectInput{
		Bucket:        aws.String(s.bucketName),
		Key:           aws.String(key),
		Body:          bytes.NewReader(fileContent),
		ContentType:   aws.String(contentType),
		ContentLength: aws.Int64(int64(len(fileContent))),
	})

	if err != nil {
		return fmt.Errorf("failed to upload file to S3: %v", err)
	}

	return nil
}

func (s *S3Service) GetFileURL(key string) string {
	return fmt.Sprintf("https://%s.s3.amazonaws.com/%s", s.bucketName, key)
}

func (s *S3Service) DeleteFile(key string) error {
	_, err := s.s3Client.DeleteObject(&s3.DeleteObjectInput{
		Bucket: aws.String(s.bucketName),
		Key:    aws.String(key),
	})

	if err != nil {
		return fmt.Errorf("failed to delete file from S3: %v", err)
	}

	return nil
}
