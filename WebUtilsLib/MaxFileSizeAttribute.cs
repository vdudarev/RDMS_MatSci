using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebUtilsLib;

public class MaxFileSizeAttribute : ValidationAttribute
{
    private readonly long _maxFileSize;

    public MaxFileSizeAttribute(long maxFileSize)
    {
        _maxFileSize = maxFileSize;
    }

    protected override ValidationResult IsValid(object value, ValidationContext validationContext)
    {
        if (value == null)
        {
            return ValidationResult.Success;
        }

        var file = value as IFormFile;

        if (file == null)
        {
            return new ValidationResult("Invalid file.");
        }

        if (file.Length > _maxFileSize)
        {
            return new ValidationResult($"File size cannot exceed {_maxFileSize} bytes.");
        }

        return ValidationResult.Success;
    }
}
